---
name: arch-fix
description: >
  Audita el proyecto completo en busca de violaciones de Clean Architecture y MVVM,
  las corrige todas, y al final verifica que SwiftLint no reporte errores.
  Usar cuando el usuario diga "audita la arquitectura", "revisa MVVM", "corrige violaciones",
  "cumple clean architecture", "/arch-fix", o pide verificar responsabilidades de capas.
---

# arch-fix

Propósito: encontrar y corregir **todas** las violaciones de Clean Architecture y MVVM en el proyecto Swift, dejando SwiftLint en 0 errores al terminar.

## Capas del proyecto

```
Domain/          → Entities, Protocols (Repository/UseCase), UseCases — SIN imports de UIKit/SwiftUI/CoreData
Data/            → Repositories (implementaciones), DTOs, Persistence — depende solo de Domain
Presentation/    → ViewModels (@Observable), Views (SwiftUI) — depende de Domain + Core
Core/            → Servicios transversales (Network, Auth, Managers) — sin dependencias de Presentation
```

## Paso 1 — Escaneo (leer, NO modificar todavía)

Ejecutar en paralelo para mapear violaciones:

```bash
grep -rn "HTTPClient\|URLSession\|URLRequest" R&M/Presentation/ --include="*.swift"
grep -rn "UserDefaults\|JSONEncoder\|JSONDecoder\|CoreData\|NSManagedObject" R&M/Presentation/ --include="*.swift"
grep -rn "LAContext\|LocalAuthentication" R&M/Presentation/ --include="*.swift"
grep -rn "import UIKit" R&M/Domain/ --include="*.swift"
grep -rn "import SwiftUI\|import UIKit" R&M/Core/ --include="*.swift"
grep -rn "LanguageManager\|ToastManager\|FavoritesManager\|BiometricAuthManager" R&M/Domain/ --include="*.swift"
grep -rn "\.shared\b" R&M/Presentation/Views/ R&M/Presentation/Characters/ R&M/Presentation/Favorites/ R&M/Presentation/Map/ R&M/Presentation/Settings/ --include="*.swift" 2>/dev/null
grep -rn "func.*async\|Task {" R&M/Presentation/.*View\.swift --include="*.swift" 2>/dev/null | grep -v "\.task\|viewModel\|\.onAppear\|\.onChange"
```

Para cada archivo sospechoso, leer sección relevante para confirmar violación.

## Paso 2 — Clasificar violaciones

Categorías y reglas de pertenencia:

| Categoría | Señal | Corrección estándar |
|---|---|---|
| **Net-in-View** | View/ViewModel llama `HTTPClient()` directo | Crear Protocol → UseCase → Repository → ViewModel |
| **Persistence-in-Presentation** | `UserDefaults`/CoreData en View o ViewModel | Crear `*RepositoryProtocol` + implementación en Data/, inyectar en Manager/ViewModel |
| **LAContext-fuera-de-Core** | `LAContext` en View o ViewModel | Mover lógica a `BiometricAuthManager` (Core) |
| **Domain-import-framework** | `import UIKit/SwiftUI` en Domain/ | Eliminar import, reescribir sin framework |
| **Shared-in-View** | View accede a `.shared` de Manager sin `@Environment` | Usar `@Environment` o recibir por init |
| **Logic-in-View** | `func` con lógica de negocio directamente en `body` o helpers de View | Mover a ViewModel dedicado |
| **NetworkError-locale** | `NetworkError.errorDescription` usa `LanguageManager` | Sacar a `func localizedMessage(lang:)` en Presentation |
| **Composition-not-root** | View crea su ViewModel con `@State private var vm = VM()` cuando VM tiene dependencias sin defaults | Crear ViewModel en ContentView, pasar como param |

## Paso 3 — Corregir en orden de dependencia (Domain → Data → Core → Presentation)

Para cada violación confirmada:

1. **Crear archivos nuevos primero** (Protocols en Domain/, implementaciones en Data/)
2. **Modificar Core** si la lógica pertenece ahí
3. **Modificar ViewModels** para recibir dependencias por init
4. **Modificar Views** para delegar al ViewModel
5. **Actualizar ContentView** como composition root si se agregaron ViewModels con deps externas

### Reglas al escribir código

- `@Observable final class` para ViewModels — NO `ObservableObject`
- DI por init con defaults `.shared` para facilitar uso sin sacrificar testabilidad
- Views: SOLO `@Environment`, `@State`, `@Bindable` — ningún `import Foundation` con lógica
- Si View necesita `$viewModel.property` → el param es `@Bindable var viewModel: VM`
- Si View solo lee → `let viewModel: VM` basta
- Nuevos archivos en `PBXFileSystemSynchronizedRootGroup` — no editar `.pbxproj`

## Paso 4 — SwiftLint

```bash
swiftlint lint --quiet
```

Para cada error reportado:
- `identifier_name` → renombrar variable corta (ej. `a`/`b` → `lhs`/`rhs`, `i` → `index`)
- `type_body_length` → extraer sub-tipos o extensiones
- `function_body_length` → extraer funciones privadas
- `force_cast` / `force_try` → reemplazar con `guard let` / `try?` + manejo
- Corregir hasta que `swiftlint lint --quiet` produzca **output vacío**

## Paso 5 — Reporte final

Listar en tabla:

```
| Archivo | Violación | Corrección aplicada |
|---------|-----------|---------------------|
| Presentation/X.swift | Net-in-View | EpisodeRepository + UseCase + ViewModel |
| ...     | ...        | ...                 |
```

Seguido de: `SwiftLint: 0 errores ✓`

## Reglas estrictas

- **Nunca** romper la dirección de dependencias: Presentation → Domain ← Data
- **Nunca** agregar `import CoreData` / `import UIKit` en Domain
- **Nunca** acceder a `.shared` directamente dentro de `body` de una View
- **No** crear abstracciones extra más allá de lo necesario para cumplir la separación
- **No** agregar `Co-Authored-By` en commits sugeridos
- Si una violación es ambigua (podría ser Core o Data), preferir Core para lógica de servicio, Data para persistencia pura

## Edge cases

- **Proyecto limpio:** reportar "Sin violaciones encontradas. SwiftLint: 0 errores."
- **Archivo modificado por linter entre lectura y escritura:** re-leer antes de escribir
- **SourceKit "Cannot find type in scope":** son errores de indexing, no de compilación — ignorar si el tipo existe en otro archivo del target
- **Nuevo ViewModel necesita `@Bindable`:** verificar si la View usa `$viewModel.*` bindings antes de decidir `let` vs `@Bindable var`
