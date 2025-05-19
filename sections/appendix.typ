#import "../lib.typ": *
#show: appendix


= Интерфейсы "Оптики" на Cangjie <app:A>
#{
  show figure: set block(breakable: true)
  figure(
    [
    ```cangjie
    sealed interface Iso<S, A> <: Lens<S, A> & Prism<S, A> {
        prop to: (S) -> A
        prop from: (A) -> S
  
        prop view: (S) -> A { get() { to } }
        prop build: (A) -> S { get() { from } }
    }
  
    sealed interface Lens<S, A> <: Affine<S, A> {
        prop view: (S) -> A
        prop update: (S, A) -> S
        prop preview: (S) -> Either<S, A> {
            get() { { source: S => Right(view(source)) } }
        }
    }
  
    sealed interface Prism<S, A> <: Affine<S, A> {
        prop preview: (S) -> Either<S, A>
        prop build: (A) -> S
        prop update: (S, A) -> S {
            get() { { _: S, focus: A => build(focus) } }
        }
    }
  
    sealed interface Affine<S, A> <: Setter<S, A> {
        prop preview: (S) -> Either<S, A>
        prop update: (S, A) -> S
  
        prop over: ((A) -> A), S) -> S {
            get() {{ modify: (A) -> A, source: S =>
                if (let Right(focus) <- preview(source)) {
                    update(source, modify(focus))
                } else { source }
            }}
        } 
    }
    sealed interface Setter<S, A> {
        prop over: ((A) -> A), S) -> S
    }
    ```],
    caption: [],
    placement: none
  )
}

= Пример теста производительности <app:B>
#{
  show figure: set block(breakable: true)
  figure(
    [
    ```cangjie
@Test
@Configure[baseline: "nativeBaseline"]
class StructMutBenchmark {
    @Bench
    func nativeBaseline(): Unit {
        var bnw_ = bow
        bnw_.x.y = "New"
        let bnw = bnw_
        test = bnw
    }

    @Bench
    func opticsBaseline(): Unit {
        let bnw = composed.update(bow, "New")
        test = bnw
    }

    @Bench
    func bestOptics(): Unit {
        let bnw = composed.update(bow, "New")
        test = bnw
    }

    @AfterAll
    func aa(): Unit {
        let _ = test
    }
}
    ```],
    caption: [],
    placement: none
  )
}

= Пример сгенерированной "Оптики"
```cangjie
public struct A {
    A(
        public let x: B,
	    public let y: String
    ) { }
}

sealed interface __OpticReg_A_impl {
    public func xOptics(_: Phantom<A>): OpticsReg<B> { OpticsReg() }
    public func yOptics(_: Phantom<A>): OpticsReg<String> { OpticsReg() }
    public func downcastDerive(_: Phantom<A>): LensReg<A> { LensReg() }
}
extend OpticsReg<A> <: __OpticsReg_A_impl { }

sealed interface __LensReg_A_impl {
    public func xImplForward(source: A): B { source.x }
    public func xImplBackward(source: A, focus: B) { A(focus, source.y) }
    public func yImplForward(source: A): String { source.y }
    public func yImplBackward(source: A, focus: String) { A(source.x, focus) }
}
extend LensReg<A> <: __OpticsReg_A_impl { }
```
= Пример сгерерированного выражения `@Optics` <app:D>
Оригинальное выражение:
```cangjie
let result = @Optics(original.serialization<Department>()
    .information
    .address
    .city = "Melbourne"
)
```
Сгенерированное:
```cangjie
let result = { => let magic0 = magic({ => original })
let optics0 = magic0.__downcast_method_serialization < Department >(magic0)
let optics0ImplForward = optics0.__method_serialization_impl_forward < Department >(magic0)
let optics0ImplBackward = optics0.__method_serialization_impl_backward < Department >(magic0)
let magic1 = magic0.__method_serialization_optics < Department >(magic0)
let optics1 = magic1.__downcast(magic1)
let __expect1 = __OpticsCompositions.opticsUpcast(optics0, optics1)
let optics1ImplForward = __OpticsCompositions.composeForward(optics0, optics1)(optics0ImplForward, optics1.__information_impl_forward)
let optics1ImplBackward = __OpticsCompositions.composeBackward(optics0, optics1)(optics0ImplForward, optics1.__information_impl_forward, optics0ImplBackward, optics1.__information_impl_backward)
let magic2 = magic1.__information_optics(magic1)
let optics2 = magic2.__downcast(magic2)
let __expect2 = __OpticsCompositions.opticsUpcast(__expect1, optics2)
let optics2ImplForward = __OpticsCompositions.composeForward(__expect1, optics2)(optics1ImplForward, optics2.__address_impl_forward)
let optics2ImplBackward = __OpticsCompositions.composeBackward(__expect1, optics2)(optics1ImplForward, optics2.__address_impl_forward, optics1ImplBackward, optics2.__address_impl_backward)
let magic3 = magic2.__address_optics(magic2)
let optics3 = magic3.__downcast(magic3)
let __expect3 = __OpticsCompositions.opticsUpcast(__expect2, optics3)
let optics3ImplBackward = __OpticsCompositions.composeBackward(__expect2, optics3)(optics2ImplForward, optics3.__city_impl_forward, optics2ImplBackward, optics3.__city_impl_backward)
evalBackward(optics3ImplBackward, original, "Melbourne") }()
```
