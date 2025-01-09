# 無料枠でできるOKE用Terraform
OCIの無料枠でもらえる4台のArmマシンでKubernetesを建てるやつ

## 使い方
### 1. `terraform.tfvars`を作成
`variables.tf`を参考に  
管理しやすくするために、指定されたコンパートメントの下にOKE用コンパートメントが建つ。

```terraform
oci_compartment_id = "ocid1.tenancy.oc1.yourcompartmentid"
oci_ssh_key        = "ssh-ed25519 yourpublickey"
```

### 2. （任意）各種リソースの名前を変更
デフォルトでは、`oke_compartment`を作り、そこに`oke`というOKEのリソースができる。

### 3. （任意）Nodeの設定を変更
デフォルトでは、無料枠の4台を全て使うのではなく、3台を使う構成になっている。  
任意で4台にするか、スペックを2倍にして2台にするなどニーズに応じて変更する。  
（3台なのは私が残りの1台をデータ保存用サーバとして使っているため）

### 3. terraform実行
initして
```sh
$ terraform init
```
planしてみて
```sh
$ terraform plan
```
実行する
```sh
$ terraform apply
```

#### 4. Kubernetesへのアクセス
CloudコンソールのOKEのページに行き、作成されたリソースを見る。ない場合、新しいコンパートメントがちゃんと選択されているかもチェックする。  
Quick Startにコマンドがあるので、これを使ってkubeconfigを入手する。あとは`kubectl`なりLensなりよしなに

## 使い方
無料枠に収めるためには多少の工夫が必要となる。

### LoadBalancer
ServiceにLoadBalancerを使うと、デフォルトではdeprecatedなロードバランサを使ってしまい課金が発生する。  
帯域10MbpsのFlexible Load BalancerかNetwork Load Balancerを使う必要がある。[ドキュメント](https://docs.oracle.com/ja-jp/iaas/Content/ContEng/Tasks/contengcreatingnetworkloadbalancers.htm)を参考にannotationsを設定する。

私はNetwork Load Balancerから[nginx-ingress-controller](https://github.com/kubernetes/ingress-nginx)に通し、Load Balancerに割り当てられたPublic IPにDNSを設定することでアクセスしている。
```yaml
annotations:
  oci.oraclecloud.com/load-balancer-type: "nlb"
```

試していないが、[cloudflare-tunnel-ingress-controller](https://github.com/STRRL/cloudflare-tunnel-ingress-controller)なんかを使うとこの辺を考えなくてよくて楽かも？

### Volume
デフォルトでは、ボリュームを作るとOCIのBlock Volume（最低50GB）が新しくできるが、これの無料枠は200GBであり、Node1台ずつにBoot Volumeが50GBずつ使われているのでカツカツになってしまう。  
Node数が4未満ならば余っている容量でBlock Volumeを割り当てても課金が発生しないが、最低50GBのVolumeを1つのPVCにしか割り当てられない微妙な仕様なのでこれは多くの人々にとっては使いづらいと思われる。

そこで、[Longhorn](https://longhorn.io/)をデプロイするとBoot Volumeをよしなに使ってくれるので、十分小さいVolumeならこれで対応できる。  
しかし容量がかなり少ないので、私はNodeと同じsubnetにComputeインスタンスを1台建てることでデータを保存している。

## Tips
### OCI無料枠について
OCIのアカウントには、Free TierアカウントとPay As You Goアカウントがある。デフォルトの前者なら課金が絶対に発生しないが、無料枠のComputeインスタンスが極めて人気なため全然確保できずエラーが出るという問題がある。後者にしても無料枠分はちゃんと無料になるため、後者にアップグレードするのが推奨される。
