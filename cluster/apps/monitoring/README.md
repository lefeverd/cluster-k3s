# Test alertmanager alert

```
kubectl port-forward svc/kube-prometheus-stack-alertmanager 9093
./test-alert.sh
```

At first, alerts weren't sent to discord.  
The alert needs to have a summary and description.
