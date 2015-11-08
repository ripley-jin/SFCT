(** * Lists: 结构化的数据 *)

Require Export Induction.

Module NatList. 

(* ###################################################### *)
(** * 数对 *)

(** 在归纳类型定义中，每个构造器（Constructor）可以有任意多个参数——没有（就像true和O），一个（就像S），或者更多，就像接下来那个定义： *)

Inductive natprod : Type :=
  pair : nat -> nat -> natprod.

(** 这个定义可以被理解作：『只有一种方式来构造一个数对：通过把pair这个构造器应用到两个nat类型的参数上』 *)

(** 我们能够向下面这样构造一个数对 *)

Check (pair 3 5).

(** *** *)

(** 下面是两个简单的函数定义，这两个函数从一个数对中分别抽取第一个和第二个分量
    （这个定义同时也展示了如何对一个两个参数的构造器进行模式匹配 *)

Definition fst (p : natprod) : nat := 
  match p with
  | pair x y => x
  end.
Definition snd (p : natprod) : nat := 
  match p with
  | pair x y => y
  end.

Eval compute in (fst (pair 3 5)).
(* ===> 3 *)

(** *** *)

(** 因为数对经常被用到，如果能有数学记号 (x,y) 来代替 pair x y 是极好的。
    我们可以教Coq接受这种记号通过申明一个Notation *)

Notation "( x , y )" := (pair x y).

(** 这个新的记号能够被用在表达式和模式匹配中（实际上，在上一章中我们已经使用过了——这个记号在标准库中已经被提供了 *)

Eval compute in (fst (3,5)).

Definition fst' (p : natprod) : nat := 
  match p with
  | (x,y) => x
  end.
Definition snd' (p : natprod) : nat := 
  match p with
  | (x,y) => y
  end.

Definition swap_pair (p : natprod) : natprod := 
  match p with
  | (x,y) => (y,x)
  end.

(** *** *)

(** 我们现在来证明一些有关数对的简单的事实。如果我们以一种特定的（稍微有点古怪）的方式来
    书写我们的引理，我们能仅仅通过 『reflexivity』（还有它背后自带的简化）来证明 *)

Theorem surjective_pairing' : forall (n m : nat),
  (n,m) = (fst (n,m), snd (n,m)).
Proof.
  reflexivity.  Qed.

(** 注意，如果我们一种自然的方式来书写这条引理的话仅仅用 『reflexivity』 是不够的 *)

Theorem surjective_pairing_stuck : forall (p : natprod),
  p = (fst p, snd p).
Proof.
  simpl. (* Doesn't reduce anything! *)
Abort.

(** *** *)
(** 我们必须要像Coq展示p的具体结构，这样simpl才能对 fst 和 snd 做模式匹配。 通过destruct可以达到这个目的。需要注意的是，不像自然数，destruct不会生成一个额外的子目标，因为只有一种方式可以构造数对 *)

Theorem surjective_pairing : forall (p : natprod),
  p = (fst p, snd p).
Proof.
  intros p.  destruct p as [n m].  simpl.  reflexivity.  Qed.

(** **** Exercise: 1 star (snd_fst_is_swap)  *)
Theorem snd_fst_is_swap : forall (p : natprod),
  (snd p, fst p) = swap_pair p.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 1 star, optional (fst_swap_is_snd)  *)
Theorem fst_swap_is_snd : forall (p : natprod),
  fst (swap_pair p) = snd p.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(* ###################################################### *)
(** * 数的列表 *)

(** 通过稍稍推广一下我们对数对的定义，我们像可以这样描述数的列表：『一个列表要么是空的，不然就应该是一个数和另一个列表的对子』 *)

Inductive natlist : Type :=
  | nil : natlist
  | cons : nat -> natlist -> natlist.

(** 比如说，这是一个有三个元素的列表 *)

Definition mylist := cons 1 (cons 2 (cons 3 nil)).


(** *** *)
(** 结项对子一样，用我们已经熟悉的编程的记号来写下一个列表会显得更为方便。下面两个声明让我们可以用『::』来作中缀cons操作符，用方括号来做『外缀』符号来构造列表 *)

Notation "x :: l" := (cons x l) (at level 60, right associativity).
Notation "[ ]" := nil.
Notation "[ x ; .. ; y ]" := (cons x .. (cons y nil) ..).

(** 完全理解这些声明是不必要的，但是假使你感兴趣的话，接下来我会粗略地介绍到底发生了什么
    right associativity 告诉 Coq 当遇到多个符号时怎么给表达式加括号。这样下面三个
    声明做的就是同一件事 *)

Definition mylist1 := 1 :: (2 :: (3 :: nil)).
Definition mylist2 := 1 :: 2 :: 3 :: nil.
Definition mylist3 := [1;2;3].

(** [at level 60]这部分告诉Coq当遇到表达式还有其他中缀符号的时应该如何加括号。举个例子，
    我们已经定义了 [+] 作为 [plus] 的中缀符号，它的level是50。
Notation "x + y" := (plus x y)  
                    (at level 50, left associativity).
    [+] 将会比 [::] 结合的更近，所以 [1 + 2 :: [3]] 会被解析成 [(1 + 2) :: [3]]，就和我们期待的一样，而不是 [1 + (2 :: [3])]

   (值得注意的是，当你在.v文件中看到"[1 + (2 :: [3])]"这样的记号会感到非常异或。里面的那个框住3的方括号，指示了其是一个列表。但是外面那个方括号，在HTML中是看不到的，是用来告诉"coqdoc"这部分要被显示为代码而非普通的文本)

   上面第二和第三个[Notation]申明引入了标准的方括号记号来表示列表；第三个声明的右边部分展示了在Coq中申明n元记号的语法以及如何把它们翻译成嵌套的二元构造器的序列 *)

(** *** Repeat *)
(** 很多有用的函数可以用来操作列表。比如[repeat]函数接受一个数[n]和[count]，返回一个长为[count]，每个元素都是[n]的列表 *)

Fixpoint repeat (n count : nat) : natlist := 
  match count with
  | O => nil
  | S count' => n :: (repeat n count')
  end.

(** *** Length *)
(** [length]函数用来计算列表的长度 *)

Fixpoint length (l:natlist) : nat := 
  match l with
  | nil => O
  | h :: t => S (length t)
  end.

(** *** Append *)
(** [app]函数用来把两个列表连接起来 *)

Fixpoint app (l1 l2 : natlist) : natlist := 
  match l1 with
  | nil    => l2
  | h :: t => h :: (app t l2)
  end.

(** 实际上，在接下来的很多地方都会用到[app]，所以如果它有一个中缀操作符的话会很方便 *)

Notation "x ++ y" := (app x y) 
                     (right associativity, at level 60).

Example test_app1:             [1;2;3] ++ [4;5] = [1;2;3;4;5].
Proof. reflexivity.  Qed.
Example test_app2:             nil ++ [4;5] = [4;5].
Proof. reflexivity.  Qed.
Example test_app3:             [1;2;3] ++ nil = [1;2;3].
Proof. reflexivity.  Qed.

(** 我们来看两个小例子，这两个例子都是有关如何编写有关列表的程序。
    [hd]函数返回列表的第一个元素（"头元素"）。类似的，[tl] 返回除了第一个元素以外
    的所有元素。
    当然，空列表没有第一个元素，所以我们必须传入一个默认值，让这个值成为这种情况下的返回值  *)

(** *** Head (with default) and Tail *)
Definition hd (default:nat) (l:natlist) : nat :=
  match l with
  | nil => default
  | h :: t => h
  end.

Definition tl (l:natlist) : natlist :=
  match l with
  | nil => nil  
  | h :: t => t
  end.

Example test_hd1:             hd 0 [1;2;3] = 1.
Proof. reflexivity.  Qed.
Example test_hd2:             hd 0 [] = 0.
Proof. reflexivity.  Qed.
Example test_tl:              tl [1;2;3] = [2;3].
Proof. reflexivity.  Qed.

(** **** Exercise: 2 stars (list_funs)  *)
(** 完成以下[nonzeros]，[oddmembers]和[countoddmembers]的定义，
    你可以查看测试函数来理解这些函数应该做什么 *)

Fixpoint nonzeros (l:natlist) : natlist :=
  (* FILL IN HERE *) admit.

Example test_nonzeros:            nonzeros [0;1;0;2;3;0;0] = [1;2;3].
 (* FILL IN HERE *) Admitted.

Fixpoint oddmembers (l:natlist) : natlist :=
  (* FILL IN HERE *) admit.

Example test_oddmembers:            oddmembers [0;1;0;2;3;0;0] = [1;3].
 (* FILL IN HERE *) Admitted.

Fixpoint countoddmembers (l:natlist) : nat :=
  (* FILL IN HERE *) admit.

Example test_countoddmembers1:    countoddmembers [1;0;3;1;4;5] = 4.
 (* FILL IN HERE *) Admitted.
Example test_countoddmembers2:    countoddmembers [0;2;4] = 0.
 (* FILL IN HERE *) Admitted.
Example test_countoddmembers3:    countoddmembers nil = 0.
 (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 3 stars, advanced (alternate)  *)
(** 完成[alternate]的定义，它把两个列表两个列表像拉链一样"拉"进一个，
    从两个列表中交替地取出元素。查看后面的tests来获得更加详细的例子

    注意：一种自然的，优雅的方法来书写[alternate]将无法满足Coq对于[Fixpoint]必须
    "显然会终止"的要求。如果你发现你被这种解法束缚住了，你可以寻找一种稍微冗长一些的解法：同时考虑两个列表。（一个可行的解法需要定义新的列表，但这不是唯一的方法） *)


Fixpoint alternate (l1 l2 : natlist) : natlist :=
  (* FILL IN HERE *) admit.


Example test_alternate1:        alternate [1;2;3] [4;5;6] = [1;4;2;5;3;6].
 (* FILL IN HERE *) Admitted.
Example test_alternate2:        alternate [1] [4;5;6] = [1;4;5;6].
 (* FILL IN HERE *) Admitted.
Example test_alternate3:        alternate [1;2;3] [4] = [1;4;2;3].
 (* FILL IN HERE *) Admitted.
Example test_alternate4:        alternate [] [20;30] = [20;30].
 (* FILL IN HERE *) Admitted. 
(** [] *)

(* ###################################################### *)
(** ** Bags via Lists *)

(** [bag]（或者叫[multiset]）就像一个集合，但是每个元素都能够出现若干次，而不是仅仅一次。
    背包一种合理的实现就是把它作为一个列表。 *)

Definition bag := natlist.  

(** **** Exercise: 3 stars (bag_functions)  *)
(** 完成下列[count], [sum], [add] 以及 [member] 的定义 *)

Fixpoint count (v:nat) (s:bag) : nat := 
  (* FILL IN HERE *) admit.

(** 这些命题都能通过[reflexivity]来证明。 *)

Example test_count1:              count 1 [1;2;3;1;4;1] = 3.
 (* FILL IN HERE *) Admitted.
Example test_count2:              count 6 [1;2;3;1;4;1] = 0.
 (* FILL IN HERE *) Admitted.

(** 多重集的[sum]非常像集合的[union]:[sum a b]包含了所有[a]和[b]的元素。（数学家对
    多重集上的[sum]的定义常常不大一样，这也是为什么我们没有使用这个名字。
    对于[sum]来说，我们给你的声明中没有给参数显式的名字。除此以外，它使用[Definition]
    而不是[Fixpont]，所以即使你给参数安排了名字，你也不能递归的处理他们。如此给出这个问题的意义
    在于鼓励你思考[sum]是否能用另一种方法实现——可能通过使用那些你已经定义过的函数.  *)

Definition sum : bag -> bag -> bag := 
  (* FILL IN HERE *) admit.

Example test_sum1:              count 1 (sum [1;2;3] [1;4;1]) = 3.
 (* FILL IN HERE *) Admitted.

Definition add (v:nat) (s:bag) : bag := 
  (* FILL IN HERE *) admit.

Example test_add1:                count 1 (add 1 [1;4;1]) = 3.
 (* FILL IN HERE *) Admitted.
Example test_add2:                count 5 (add 1 [1;4;1]) = 0.
 (* FILL IN HERE *) Admitted.

Definition member (v:nat) (s:bag) : bool := 
  (* FILL IN HERE *) admit.

Example test_member1:             member 1 [1;4;1] = true.
 (* FILL IN HERE *) Admitted.
Example test_member2:             member 2 [1;4;1] = false.
 (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 3 stars, optional (bag_more_functions)  *)
(** 你可以把下面这些和[bag]有关的函数当做额外的联系 *)

Fixpoint remove_one (v:nat) (s:bag) : bag :=
  (* 当[remove_one]被应用到一个没有书可以移除的背包时，它应该返回原来的那个，不做任何改变。 *)
  (* FILL IN HERE *) admit.

Example test_remove_one1:         count 5 (remove_one 5 [2;1;5;4;1]) = 0.
 (* FILL IN HERE *) Admitted.
Example test_remove_one2:         count 5 (remove_one 5 [2;1;4;1]) = 0.
 (* FILL IN HERE *) Admitted.
Example test_remove_one3:         count 4 (remove_one 5 [2;1;4;5;1;4]) = 2.
 (* FILL IN HERE *) Admitted.
Example test_remove_one4:         count 5 (remove_one 5 [2;1;5;4;5;1;4]) = 1.
 (* FILL IN HERE *) Admitted.

Fixpoint remove_all (v:nat) (s:bag) : bag :=
  (* FILL IN HERE *) admit.

Example test_remove_all1:          count 5 (remove_all 5 [2;1;5;4;1]) = 0.
 (* FILL IN HERE *) Admitted.
Example test_remove_all2:          count 5 (remove_all 5 [2;1;4;1]) = 0.
 (* FILL IN HERE *) Admitted.
Example test_remove_all3:          count 4 (remove_all 5 [2;1;4;5;1;4]) = 2.
 (* FILL IN HERE *) Admitted.
Example test_remove_all4:          count 5 (remove_all 5 [2;1;5;4;5;1;4;5;1;4]) = 0.
 (* FILL IN HERE *) Admitted.

Fixpoint subset (s1:bag) (s2:bag) : bool :=
  (* FILL IN HERE *) admit.

Example test_subset1:              subset [1;2] [2;1;4;1] = true.
 (* FILL IN HERE *) Admitted.
Example test_subset2:              subset [1;2;2] [2;1;4;1] = false.
 (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 3 stars (bag_theorem)  *)
(** 写下一个你认为有趣的关于[bags]的定理[bag_theorem]，要涉及到[count]和[add]。
    证明他。注意，这个问题是开放的，很有可能你会遇到你写下了正确的定理，
    但是其证明涉及到了你现在还没有学到的技巧。如果你陷入麻烦了，欢迎提问。 *)

(* FILL IN HERE *)
(** [] *)

(* ###################################################### *)
(** * 有关列表的推理 *)

(** 就像数字一样，一些简单的有关处理列表事实，有时也能仅仅通过化简来证明。
    比方说，对于下面这个例子，[reflexivity]中所做的简化就已经足够了…… *)

Theorem nil_app : forall l:natlist,
  [] ++ l = l.
Proof. reflexivity. Qed.

(** ……由于[[]]被替换进了[app]定义中的相应的match分支，这就使得整个[match]得以被简化并证明目标 *)

(** 并且，和数一样，又是对一个列表做分类讨论（是否是空）是非常有用的。 *)

Theorem tl_length_pred : forall l:natlist,
  pred (length l) = length (tl l).
Proof.
  intros l. destruct l as [| n l'].
  Case "l = nil".
    reflexivity.
  Case "l = cons n l'". 
    reflexivity.  Qed.

(** 这里，如此解决[nil]这种情况是因为我们定义了[tl nil = nil]。至于[destruct]策略中的[as]注解
    引入了两个名字，[n]和[l']， 分别对应了[cons]构造子的两个参数（正在构造的列表的头和尾） *)

(** 经常，如果你不是那么相信的话，要证明关于列表的有趣的定理需要用到归纳法 *)

(* ###################################################### *)
(** ** 一点点说教 *)

(** 知识阅读示例证明脚本的话，你不会获得什么特别有用的东西。搞清楚每一个的细节是非常重要的
    使用Coq并思考有关每一步是如何得到的。否则这或多或少保证了联系题讲一点都没有用 *)

(* ###################################################### *)
(** ** Induction on Lists *)

(** Proofs by induction over datatypes like [natlist] are
    perhaps a little less familiar than standard natural number
    induction, but the basic idea is equally simple.  Each [Inductive]
    declaration defines a set of data values that can be built up from
    the declared constructors: a boolean can be either [true] or
    [false]; a number can be either [O] or [S] applied to a number; a
    list can be either [nil] or [cons] applied to a number and a list.

    Moreover, applications of the declared constructors to one another
    are the _only_ possible shapes that elements of an inductively
    defined set can have, and this fact directly gives rise to a way
    of reasoning about inductively defined sets: a number is either
    [O] or else it is [S] applied to some _smaller_ number; a list is
    either [nil] or else it is [cons] applied to some number and some
    _smaller_ list; etc. So, if we have in mind some proposition [P]
    that mentions a list [l] and we want to argue that [P] holds for
    _all_ lists, we can reason as follows:

      - First, show that [P] is true of [l] when [l] is [nil].

      - Then show that [P] is true of [l] when [l] is [cons n l'] for
        some number [n] and some smaller list [l'], assuming that [P]
        is true for [l'].

    Since larger lists can only be built up from smaller ones,
    eventually reaching [nil], these two things together establish the
    truth of [P] for all lists [l].  Here's a concrete example: *)

Theorem app_assoc : forall l1 l2 l3 : natlist, 
  (l1 ++ l2) ++ l3 = l1 ++ (l2 ++ l3).   
Proof.
  intros l1 l2 l3. induction l1 as [| n l1'].
  Case "l1 = nil".
    reflexivity.
  Case "l1 = cons n l1'".
    simpl. rewrite -> IHl1'. reflexivity.  Qed.

(** Again, this Coq proof is not especially illuminating as a
    static written document -- it is easy to see what's going on if
    you are reading the proof in an interactive Coq session and you
    can see the current goal and context at each point, but this state
    is not visible in the written-down parts of the Coq proof.  So a
    natural-language proof -- one written for human readers -- will
    need to include more explicit signposts; in particular, it will
    help the reader stay oriented if we remind them exactly what the
    induction hypothesis is in the second case.  *)

(** *** Informal version *)

(** _Theorem_: For all lists [l1], [l2], and [l3], 
   [(l1 ++ l2) ++ l3 = l1 ++ (l2 ++ l3)].

   _Proof_: By induction on [l1].

   - First, suppose [l1 = []].  We must show
       ([] ++ l2) ++ l3 = [] ++ (l2 ++ l3),
     which follows directly from the definition of [++].

   - Next, suppose [l1 = n::l1'], with
       (l1' ++ l2) ++ l3 = l1' ++ (l2 ++ l3)
     (the induction hypothesis). We must show
       ((n :: l1') ++ l2) ++ l3 = (n :: l1') ++ (l2 ++ l3).
]]  
     By the definition of [++], this follows from
       n :: ((l1' ++ l2) ++ l3) = n :: (l1' ++ (l2 ++ l3)),
     which is immediate from the induction hypothesis.  []
*)

(** *** Another example *)
(**
  Here is a similar example to be worked together in class: *)

Theorem app_length : forall l1 l2 : natlist, 
  length (l1 ++ l2) = (length l1) + (length l2).
Proof.
  (* WORKED IN CLASS *)
  intros l1 l2. induction l1 as [| n l1'].
  Case "l1 = nil".
    reflexivity.
  Case "l1 = cons".
    simpl. rewrite -> IHl1'. reflexivity.  Qed.


(** *** Reversing a list *)
(** For a slightly more involved example of an inductive proof
    over lists, suppose we define a "cons on the right" function
    [snoc] like this... *)

Fixpoint snoc (l:natlist) (v:nat) : natlist := 
  match l with
  | nil    => [v]
  | h :: t => h :: (snoc t v)
  end.

(** ... and use it to define a list-reversing function [rev]
    like this: *)

Fixpoint rev (l:natlist) : natlist := 
  match l with
  | nil    => nil
  | h :: t => snoc (rev t) h
  end.

Example test_rev1:            rev [1;2;3] = [3;2;1].
Proof. reflexivity.  Qed.
Example test_rev2:            rev nil = nil.
Proof. reflexivity.  Qed.

(** *** Proofs about reverse *)
(** Now let's prove some more list theorems using our newly
    defined [snoc] and [rev].  For something a little more challenging
    than the inductive proofs we've seen so far, let's prove that
    reversing a list does not change its length.  Our first attempt at
    this proof gets stuck in the successor case... *)

Theorem rev_length_firsttry : forall l : natlist,
  length (rev l) = length l.
Proof.
  intros l. induction l as [| n l'].
  Case "l = []".
    reflexivity.
  Case "l = n :: l'".
    (* This is the tricky case.  Let's begin as usual 
       by simplifying. *)
    simpl. 
    (* Now we seem to be stuck: the goal is an equality 
       involving [snoc], but we don't have any equations 
       in either the immediate context or the global 
       environment that have anything to do with [snoc]! 

       We can make a little progress by using the IH to 
       rewrite the goal... *)
    rewrite <- IHl'.
    (* ... but now we can't go any further. *)
Abort.

(** So let's take the equation about [snoc] that would have
    enabled us to make progress and prove it as a separate lemma. 
*)

Theorem length_snoc : forall n : nat, forall l : natlist,
  length (snoc l n) = S (length l).
Proof.
  intros n l. induction l as [| n' l'].
  Case "l = nil".
    reflexivity.
  Case "l = cons n' l'".
    simpl. rewrite -> IHl'. reflexivity.  Qed. 

(**
    Note that we make the lemma as _general_ as possible: in particular,
    we quantify over _all_ [natlist]s, not just those that result
    from an application of [rev]. This should seem natural, 
    because the truth of the goal clearly doesn't depend on 
    the list having been reversed.  Moreover, it is much easier
    to prove the more general property. 
*)
    
(** Now we can complete the original proof. *)

Theorem rev_length : forall l : natlist,
  length (rev l) = length l.
Proof.
  intros l. induction l as [| n l'].
  Case "l = nil".
    reflexivity.
  Case "l = cons".
    simpl. rewrite -> length_snoc. 
    rewrite -> IHl'. reflexivity.  Qed.

(** For comparison, here are informal proofs of these two theorems: 

    _Theorem_: For all numbers [n] and lists [l],
       [length (snoc l n) = S (length l)].
 
    _Proof_: By induction on [l].

    - First, suppose [l = []].  We must show
        length (snoc [] n) = S (length []),
      which follows directly from the definitions of
      [length] and [snoc].

    - Next, suppose [l = n'::l'], with
        length (snoc l' n) = S (length l').
      We must show
        length (snoc (n' :: l') n) = S (length (n' :: l')).
      By the definitions of [length] and [snoc], this
      follows from
        S (length (snoc l' n)) = S (S (length l')),
]] 
      which is immediate from the induction hypothesis. [] *)
                        
(** _Theorem_: For all lists [l], [length (rev l) = length l].
    
    _Proof_: By induction on [l].  

      - First, suppose [l = []].  We must show
          length (rev []) = length [],
        which follows directly from the definitions of [length] 
        and [rev].
    
      - Next, suppose [l = n::l'], with
          length (rev l') = length l'.
        We must show
          length (rev (n :: l')) = length (n :: l').
        By the definition of [rev], this follows from
          length (snoc (rev l') n) = S (length l')
        which, by the previous lemma, is the same as
          S (length (rev l')) = S (length l').
        This is immediate from the induction hypothesis. [] *)

(** Obviously, the style of these proofs is rather longwinded
    and pedantic.  After the first few, we might find it easier to
    follow proofs that give fewer details (since we can easily work
    them out in our own minds or on scratch paper if necessary) and
    just highlight the non-obvious steps.  In this more compressed
    style, the above proof might look more like this: *)

(** _Theorem_:
     For all lists [l], [length (rev l) = length l].

    _Proof_: First, observe that
       length (snoc l n) = S (length l)
     for any [l].  This follows by a straightforward induction on [l].
     The main property now follows by another straightforward
     induction on [l], using the observation together with the
     induction hypothesis in the case where [l = n'::l']. [] *)

(** Which style is preferable in a given situation depends on
    the sophistication of the expected audience and on how similar the
    proof at hand is to ones that the audience will already be
    familiar with.  The more pedantic style is a good default for
    present purposes. *)

(* ###################################################### *)
(** ** [SearchAbout] *)

(** We've seen that proofs can make use of other theorems we've
    already proved, using [rewrite], and later we will see other ways
    of reusing previous theorems.  But in order to refer to a theorem,
    we need to know its name, and remembering the names of all the
    theorems we might ever want to use can become quite difficult!  It
    is often hard even to remember what theorems have been proven,
    much less what they are named.

    Coq's [SearchAbout] command is quite helpful with this.  Typing
    [SearchAbout foo] will cause Coq to display a list of all theorems
    involving [foo].  For example, try uncommenting the following to
    see a list of theorems that we have proved about [rev]: *)

(*  SearchAbout rev. *)

(** Keep [SearchAbout] in mind as you do the following exercises and
    throughout the rest of the course; it can save you a lot of time! *)

(** Also, if you are using ProofGeneral, you can run [SearchAbout]
    with [C-c C-a C-a]. Pasting its response into your buffer can be
    accomplished with [C-c C-;]. *)

(* ###################################################### *)
(** ** List Exercises, Part 1 *)

(** **** Exercise: 3 stars (list_exercises)  *)
(** More practice with lists. *)

Theorem app_nil_end : forall l : natlist, 
  l ++ [] = l.   
Proof.
  (* FILL IN HERE *) Admitted.


Theorem rev_involutive : forall l : natlist,
  rev (rev l) = l.
Proof.
  (* FILL IN HERE *) Admitted.

(** There is a short solution to the next exercise.  If you find
    yourself getting tangled up, step back and try to look for a
    simpler way. *)

Theorem app_assoc4 : forall l1 l2 l3 l4 : natlist,
  l1 ++ (l2 ++ (l3 ++ l4)) = ((l1 ++ l2) ++ l3) ++ l4.
Proof.
  (* FILL IN HERE *) Admitted.

Theorem snoc_append : forall (l:natlist) (n:nat),
  snoc l n = l ++ [n].
Proof.
  (* FILL IN HERE *) Admitted.


Theorem distr_rev : forall l1 l2 : natlist,
  rev (l1 ++ l2) = (rev l2) ++ (rev l1).
Proof.
  (* FILL IN HERE *) Admitted.

(** An exercise about your implementation of [nonzeros]: *)

Lemma nonzeros_app : forall l1 l2 : natlist,
  nonzeros (l1 ++ l2) = (nonzeros l1) ++ (nonzeros l2).
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 2 stars (beq_natlist)  *)
(** Fill in the definition of [beq_natlist], which compares
    lists of numbers for equality.  Prove that [beq_natlist l l]
    yields [true] for every list [l]. *)

Fixpoint beq_natlist (l1 l2 : natlist) : bool :=
  (* FILL IN HERE *) admit.

Example test_beq_natlist1 :   (beq_natlist nil nil = true).
 (* FILL IN HERE *) Admitted.
Example test_beq_natlist2 :   beq_natlist [1;2;3] [1;2;3] = true.
 (* FILL IN HERE *) Admitted.
Example test_beq_natlist3 :   beq_natlist [1;2;3] [1;2;4] = false.
 (* FILL IN HERE *) Admitted.

Theorem beq_natlist_refl : forall l:natlist,
  true = beq_natlist l l.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(* ###################################################### *)
(** ** List Exercises, Part 2 *)

(** **** Exercise: 2 stars (list_design)  *)
(** Design exercise: 
     - Write down a non-trivial theorem [cons_snoc_app]
       involving [cons] ([::]), [snoc], and [app] ([++]).  
     - Prove it. *) 

(* FILL IN HERE *)
(** [] *)

(** **** Exercise: 3 stars, advanced (bag_proofs)  *)
(** Here are a couple of little theorems to prove about your
    definitions about bags earlier in the file. *)

Theorem count_member_nonzero : forall (s : bag),
  ble_nat 1 (count 1 (1 :: s)) = true.
Proof.
  (* FILL IN HERE *) Admitted.

(** The following lemma about [ble_nat] might help you in the next proof. *)

Theorem ble_n_Sn : forall n,
  ble_nat n (S n) = true.
Proof.
  intros n. induction n as [| n'].
  Case "0".  
    simpl.  reflexivity.
  Case "S n'".
    simpl.  rewrite IHn'.  reflexivity.  Qed.

Theorem remove_decreases_count: forall (s : bag),
  ble_nat (count 0 (remove_one 0 s)) (count 0 s) = true.
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 3 stars, optional (bag_count_sum)  *)  
(** Write down an interesting theorem [bag_count_sum] about bags 
    involving the functions [count] and [sum], and prove it.*)

(* FILL IN HERE *)
(** [] *)

(** **** Exercise: 4 stars, advanced (rev_injective)  *)
(** Prove that the [rev] function is injective, that is,

    forall (l1 l2 : natlist), rev l1 = rev l2 -> l1 = l2.

There is a hard way and an easy way to solve this exercise.
*)

(* FILL IN HERE *)
(** [] *)


(* ###################################################### *)
(** * Options *)


(** One use of [natoption] is as a way of returning "error
    codes" from functions.  For example, suppose we want to write a
    function that returns the [n]th element of some list.  If we give
    it type [nat -> natlist -> nat], then we'll have to return some
    number when the list is too short! *)

Fixpoint index_bad (n:nat) (l:natlist) : nat :=
  match l with
  | nil => 42  (* arbitrary! *)
  | a :: l' => match beq_nat n O with 
               | true => a 
               | false => index_bad (pred n) l' 
               end
  end.

(** *** *)
(** On the other hand, if we give it type [nat -> natlist ->
    natoption], then we can return [None] when the list is too short
    and [Some a] when the list has enough members and [a] appears at
    position [n]. *)

Inductive natoption : Type :=
  | Some : nat -> natoption
  | None : natoption.  


Fixpoint index (n:nat) (l:natlist) : natoption :=
  match l with
  | nil => None 
  | a :: l' => match beq_nat n O with 
               | true => Some a
               | false => index (pred n) l' 
               end
  end.

Example test_index1 :    index 0 [4;5;6;7]  = Some 4.
Proof. reflexivity.  Qed.
Example test_index2 :    index 3 [4;5;6;7]  = Some 7.
Proof. reflexivity.  Qed.
Example test_index3 :    index 10 [4;5;6;7] = None.
Proof. reflexivity.  Qed.

(** This example is also an opportunity to introduce one more
    small feature of Coq's programming language: conditional
    expressions... *)

(** *** *)

Fixpoint index' (n:nat) (l:natlist) : natoption :=
  match l with
  | nil => None 
  | a :: l' => if beq_nat n O then Some a else index' (pred n) l'
  end.

(** Coq's conditionals are exactly like those found in any other
    language, with one small generalization.  Since the boolean type
    is not built in, Coq actually allows conditional expressions over
    _any_ inductively defined type with exactly two constructors.  The
    guard is considered true if it evaluates to the first constructor
    in the [Inductive] definition and false if it evaluates to the
    second. *)

(** The function below pulls the [nat] out of a [natoption], returning
    a supplied default in the [None] case. *)

Definition option_elim (d : nat) (o : natoption) : nat :=
  match o with
  | Some n' => n'
  | None => d
  end.

(** **** Exercise: 2 stars (hd_opt)  *)
(** Using the same idea, fix the [hd] function from earlier so we don't
   have to pass a default element for the [nil] case.  *)

Definition hd_opt (l : natlist) : natoption :=
  (* FILL IN HERE *) admit.

Example test_hd_opt1 : hd_opt [] = None.
 (* FILL IN HERE *) Admitted.

Example test_hd_opt2 : hd_opt [1] = Some 1.
 (* FILL IN HERE *) Admitted.

Example test_hd_opt3 : hd_opt [5;6] = Some 5.
 (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 1 star, optional (option_elim_hd)  *)
(** This exercise relates your new [hd_opt] to the old [hd]. *)

Theorem option_elim_hd : forall (l:natlist) (default:nat),
  hd default l = option_elim default (hd_opt l).
Proof.
  (* FILL IN HERE *) Admitted.
(** [] *)

(* ###################################################### *)
(** * Dictionaries *)

(** As a final illustration of how fundamental data structures
    can be defined in Coq, here is the declaration of a simple
    [dictionary] data type, using numbers for both the keys and the
    values stored under these keys.  (That is, a dictionary represents
    a finite map from numbers to numbers.) *)

Module Dictionary.

Inductive dictionary : Type :=
  | empty  : dictionary 
  | record : nat -> nat -> dictionary -> dictionary. 

(** This declaration can be read: "There are two ways to construct a
    [dictionary]: either using the constructor [empty] to represent an
    empty dictionary, or by applying the constructor [record] to
    a key, a value, and an existing [dictionary] to construct a
    [dictionary] with an additional key to value mapping." *)

Definition insert (key value : nat) (d : dictionary) : dictionary :=
  (record key value d).

(** Here is a function [find] that searches a [dictionary] for a
    given key.  It evaluates evaluates to [None] if the key was not
    found and [Some val] if the key was mapped to [val] in the
    dictionary. If the same key is mapped to multiple values, [find]
    will return the first one it finds. *)

Fixpoint find (key : nat) (d : dictionary) : natoption := 
  match d with 
  | empty         => None
  | record k v d' => if (beq_nat key k) 
                       then (Some v) 
                       else (find key d')
  end.



(** **** Exercise: 1 star (dictionary_invariant1)  *)
(** Complete the following proof. *)

Theorem dictionary_invariant1' : forall (d : dictionary) (k v: nat),
  (find k (insert k v d)) = Some v.
Proof.
 (* FILL IN HERE *) Admitted.
(** [] *)

(** **** Exercise: 1 star (dictionary_invariant2)  *)
(** Complete the following proof. *)

Theorem dictionary_invariant2' : forall (d : dictionary) (m n o: nat),
  beq_nat m n = false -> find m d = find m (insert n o d).
Proof.
 (* FILL IN HERE *) Admitted.
(** [] *)



End Dictionary.

End NatList.

(** $Date: 2014-12-31 11:17:56 -0500 (Wed, 31 Dec 2014) $ *)

