#import "../lib.typ": *

= Примеры и тест производительности <chapter4>
Проверим степень замедления на различную глубину
#figure(
  table(
    columns: 2,
    [#v(3.4em)*Глубина 2*], [#three-line-table[
    | Сценарий  |  Медиана | Погр.     |  Среднее | Отн. base. |
    | :-------- | --------:| ---------:| --------:| ----------:|
    | конструкторы   | 43.21 ns |  ±0.425 ns | 43.17 ns |   100% |
    | "через точку"  | 1.931 ns | ±0.0235 ns | 1.931 ns | -95.5% |
    | `@Optics`      | 42.93 ns |  ±0.483 ns | 42.52 ns |  -0.7% |
    ]],
    
    [#v(3.4em)*Глубина 5*], [#three-line-table[
    | Сценарий  |  Медиана  | Погр.     |  Среднее | Отн. base. |
    | :-------- | --------:| ---------:| --------:| ----------:|
    | конструкторы   | 102.4 ns |   ±1.114 ns | 97.99 ns |   100% |
    | "через точку"  | 3.319 ns | ±0.00693 ns | 3.321 ns | -96.8% |
    | `@Optics`      | 100.1 ns |   ±1.034 ns | 96.55 ns |  -2.2% |
    ]],
    
    [#v(3.4em)*Глубина 10*], [#three-line-table[
    | Сценарий  |  Медиана | Погр.     |  Среднее | Отн. base. |
    | конструкторы   | 167.5 ns |  ±2.765 ns | 189.9 ns |   100% |
    | "через точку"  | 7.637 ns | ±0.0222 ns | 7.653 ns | -95.4% |
    | `@Optics`      | 249.1 ns |  ±4.650 ns | 294.2 ns | +48.7% |
    ]],
    stroke: (x: 0pt, y: 0pt),
    align: (center, center),
    inset: 5pt,
  ),
  caption: [Тест производительности финальной модели для различных глубин],
  // placement: auto
)
На последнем тесте, предположительно, был превышен threshold на глубину инлайнинга, установленный в компиляторе, поэтому код сильно медленнее.

Рассмотрим упрощенную версию кода одного из примеров с первой главы. В качестве baseline выступает замер производительности оригинального
```cangjie
let newDep = @Optics(department
  .employees
  .selectFirst({ e => e.name == "Mark"})
  .salary, { value: Int64 => value * 2})
```
#figure(
  table(
    columns: 2,
    [#v(3.4em)*Размер 5*], [#three-line-table[
    | Сценарий  |  Медиана | Погр.     |  Среднее | Отн. base. |
    | :-------- | --------:| ---------:| --------:| ----------:|
    | baseline  | 363.2 ns | ±12.66 ns | 387.9 ns |       100% |
    | `@Optics` | 410.9 ns | ±11.50 ns | 445.0 ns |     +13.1% |
    ]],
    
    [#v(3.4em)*Размер 100*], [#three-line-table[
    | Сценарий  |  Медиана  | Погр.     |  Среднее | Отн. base. |
    |:--------- | --------: | ---------:| --------:| ----------:|
    | baseline  | 8.251 us  | ±0.155 us | 9.009 us |       100% |
    | `@Optics` | 9.446 us  | ±0.157 us | 10.35 us |     +14.5% |
    ]],
    
    [#v(3.4em)*Размер 10000*], [#three-line-table[
    | Сценарий  |  Медиана | Погр.     |  Среднее | Отн. base. |
    | :-------- | --------:| ---------:| --------:| ----------:|
    | baseline  | 1.042 ms | ±0.138 ms | 1.197 ms |       100% |
    | `@Optics` | 1.217 ms | ±0.131 ms | 1.393 ms |     +16.8% |
    ]],
    stroke: (x: 0pt, y: 0pt),
    align: (center, center),
    inset: 5pt,
  ),
  caption: [Тест производительности для различных размеров массива.],
  // placement: auto
)

```cangjie
struct Department {
    Department(
        let name: String,
        let employees: Array<Employee>,
        let information: Info
    ) { }
}

struct Info {
    Info(
        let cap: Int64,
        let address: Address
    ) { }
}

struct Address {
    Address(
       let country: String,
       let city: String
    ) { }
}
```
```cangjie
@Optics(source.serialization
   .name = "Updated Name")

@Optics(source.serialization
  .information
  .address
  .city = "Atlanta")
```
#figure(
  table(
    columns: 2,
    [#v(3.4em)*Глубина 1*], [#three-line-table[
    | Сценарий  |  Медиана | Погр.      |  Среднее | Отн. base. |
    |:----------|---------:|-----------:|---------:|-------:|
    | baseline  | 3.024 us | ±0.0526 us | 3.222 us |   100% |
    | `@Optics` | 3.015 us | ±0.0309 us | 3.233 us |  -0.3% |
    ]],
    
    [#v(3.4em)*Глубина 4*], [#three-line-table[
    | Сценарий  |  Медиана  | Погр.     |  Среднее | Отн. base. |
    |:--------- | --------: | ---------:| --------:| ----------:|
    | baseline  | 3.732 us |  ±0.148 us | 3.927 us |   100% |
    | `@Optics` | 5.063 us | ±0.0832 us | 5.608 us | +35.7% |
    ]],
    stroke: (x: 0pt, y: 0pt),
    align: (center, center),
    inset: 5pt,
  ),
  caption: [Тест производительности: десериализация + обновление + сериализация],
  // placement: auto
)

#TODO[Приведи к удобоваримому виду]
#TODO[Результаты, объем написанного кода, объем уменьшенного кода]
