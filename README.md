# karpenter-test

## EKS構築

EKS構築はTerraformを用いて行います。

```shell
$ cd env/sandbox
```

1. tfstateを管理するS3bucketを指定する

```shell
$ cp terraform.tfbackend.sample ./terraform.tfbackend
```

terraform.tfbackendの各項目を記載する。

2. 外部から与える変数をtfvarsに入力する

```shell
$ cp terraform.tfvars.sample ./terraform.tfvars
```

terraform.tfvarsの各項目を記載する。

3. Init

```shell
$ terraform init --backend-config=terraform.tfbackend
```

4. apply

```shell
$ terraform plan
// 確認
$ terraform apply
```

## Karpenterのインストール

helmfileを用いて行う。

```shell
$ cd manifests/
$ helmfile -f helmfile.yaml sync
```

## マニフェストについて

app1は`nodeSelector`を用いてにPod配置を設定しています。そのためprovisionerで指定のラベルを付与するように合わせて設定しています。

app2は`taints/tolerations`を用いてにPod配置を設定しています。そのためprovisionerで指定のtaintsを付与するように合わせて設定しています。

* appX-provisioner.yaml: appXのPodをスケジュールするためのノードに合わせた設定ファイル
* appX-deployment.yaml: appXのPodを作成するデプロイメントリソース

## Karpenterの動作確認

1. provisionerをデプロイする

```shell
$ cd manifests/
$ kubectl apply -f appX-provisioner.yaml
```

2. Podを作成し、ノード追加が行われることを確認する

```shell
$ kubectl apply -f appX-deployment.yaml
$ kubectl get pod
```

どのprovisionerが参照されたかはlogを見ることで確認できます。

```shell
$ kubectl -n karpenter logs karpenter-xxxxxxxx
```

3. ノード削除が行われることを確認する

```shell
$ kubectl scale deployment appX --replicas 0
$ kubectl get node
```