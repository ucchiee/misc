# glibc_malloc

malloc 動画を見ている際のメモ

かなり見づらい

- K&R malloc は古い
  - 小さい領域を malloc しまくると、性能悪化
  - フラグメンテーションが大問題
- best fit allocator にする(K&R は first fit だったかな)
  - malloc header にメンバを増やす
    - prev_size, size, fd, bd というメンバ
    - header サイズの分だけ空間効率が悪くなる
- ヘッダのダイエット
  - 割り付け済みのヘッダには bk, fd は不要
- 続き
  - prev_size は prev が free 状態の時のみに必要
  - どうやって判定する？
- どうやって
  - ポインタの下位 2bit は 0 だよね
  - glibc なら 3bit が 0
- 下位 bit をフラグとして使おう!
  - 下位 1bit が 1 だったら、前の block は使用状態。0 だったら未使用状態
  - 1 だったら prev_size を削れる
  - メモリ上で可変長
- 時系列で確認
  - よく見るとあっている
- original
  - dl-malloc
    - ダグリーさん、ホームページに資料が置いてある
    - 資料は古い
    - 5KLoC
  - pt-malloc
    - multi thread
    - ver2 を glib で使っている
- small bin
  - サイズ 16 用のリスト, サイズ 24 用のリスト、...と言う感じのリストを持っておく
  - best fit かつ O(1)
  - サイズは 512B 以下
    - 512 以上のサイズはないよねぇ
  - 配列 1 つを bin と読んでる
- large bin を作って、512B 以上にも対応する
  - どんどん大きくする
  - 幅をどんどん大きくする
- どう頑張っても、ラストの bin はいっぱい使ってしまう
  - そのための mmap
- anonymous mamp
  - mmpa、fd の引数に"/dev/zero"を渡すと、メモリ確保としても使える
  - 下から 2bit 目を mmap で取ったよ。の flag に
    - flag がたってると、munmap()を使うよ
- 今は 1K 以上が huge で、mmap()される
  - large bin は調整できるが、bin は 756K なので、threshold は 1M 以下で調整してほしいよ
- 利点
  - フラグメンテーションが起きにくくなる
  - メモリの無駄が少ない
  - mmap/munmap を走らせまくると、性能が劣化する
    - 定石としては、threshold を 0 にして mmap が走らないようにする
    - uunmap()の TLB flush がきつい
- 良い点
  - malloc / free が typical で O(1)
  - フラグメンテーションが起きづらい
  - ヘッダサイズは実質 4B
- キャッシュと局所性
  - malloc 直後、free 直前は触っている可能性が高い
  - 直前に free されたメモリは速い、K&R はそこを返している
- バッファの遅延合体

  - すぐに合体させない
  - free した側からユーザーに渡すと、キャッシュ効率がよい
  - bin[0]と bin[1]は未使用
    - 最低確保サイズが 32 なので
  - bin[1]につないでいく
    - 時系列順になる
    - キャッシュに乗っているブロックを渡せる可能性がたかい
    - が、unsorted-list なので、希望のサイズがなかったら、通常の bin を見る
  - 定常状態ではこの戦略が有利
    - バースト状態では少し不利になる
      - free を打ちまくると、unsorted-list から本来の bin に繋げまくる状態
    - が、もともとバースト状態では遅いのでいいじゃーん

- 以下はマルチスレッド
- Arena
  - もしくは pool と呼ぶらしい
  - main thread は main arena
- 新しい heap を mmap で作成
  - 1M
  - この alternative heap を arena
  - TLS(thread local storage) に自分用 arena を覚えておく
- さらに thread ができたとする
  - main arena アクセス → second arena アクセス → 自分用 arena 作成
    - ガラ空きarenaを検出するために、以前のarenaを探しにいく
    - 空間効率を重視
- 1 thread 1 arenaの利点
  - thread は別のCPUで動いている可能性がある
    - thread専用メモリを使うとキャッシュヒット率がものすごくアップ
- arena 1M align すればよい
