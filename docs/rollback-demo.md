# Rollback demo: ship a bad release, then `helm rollback`

The brief asks us to ship a bad release on purpose and roll it back live. Rehearsed on a local
cluster; the commands are the same on EKS.

## Why the site stays up during a bad release

Every Deployment in the chart uses `maxUnavailable: 0`: Kubernetes only removes an old pod once
its replacement is ready. A broken release never becomes ready, so the old pods keep serving.

## 1. Show the healthy starting point

```bash
helm history voting-app -n voting-app
kubectl get pods -n voting-app
```

Note the last `deployed` revision number. That's the one we roll back to.

## 2. Ship the bad release

This release points at an image tag that doesn't exist. `--reuse-values` keeps every other setting
(including the database password) from the running release.

```bash
helm upgrade voting-app ./helm/voting-app -n voting-app \
  --reuse-values --set image.tag=does-not-exist \
  --wait --timeout 90s
```

What you'll see:
- the command fails with `context deadline exceeded`
- `kubectl get pods -n voting-app` shows new pods stuck in `ErrImagePull` / `ImagePullBackOff`
  next to the old pods, which are still `Running`
- the vote page still loads (old pods are serving)
- `helm history voting-app -n voting-app` shows the new revision as `failed`

## 3. Roll back

```bash
helm rollback voting-app <last good revision> -n voting-app --wait
```

## 4. Prove it's fixed

```bash
helm history voting-app -n voting-app        # new revision: "Rollback to <n>", status deployed
kubectl get pods -n voting-app               # broken pods gone, all Running
kubectl get deploy vote -n voting-app \
  -o jsonpath='{.spec.template.spec.containers[0].image}'   # back on the good commit SHA
```

Cast a vote to show the app works, and that votes from before the bad release are still there
(Postgres keeps them on its persistent volume).
