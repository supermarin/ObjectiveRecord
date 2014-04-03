## 1.5

#### Breaking changes

- `+mappings` are now a class method!

- Added support for variadic arguments in `+where:`, `+find:`, and
  `+countWhere:`. (This also removes the now-redundant `+whereFormat:`.)

#### Enhancements

- Formatted arguments now use `+predicateWithFormat:` instead of
  `+stringWithFormat:` (to enforce proper predicate quoting).

- `+find:` now supports predicates.


## 1.2

#### Features

- Added model mappings. Vanilla snake_case to camelCase happens automatically.
  For custom keys, override `-mappings` in your `NSManagedObject` subclass.
