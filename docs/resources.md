# Resources

## Documentation

- [Flux Documentation](https://fluxcd.io/flux/){ target="_blank" }
- [Flux Operator Documentation](https://fluxoperator.dev/){ target="_blank" }
- [OpenGitOps Principles](https://opengitops.dev/){ target="_blank" }
- [Kustomize Documentation](https://kustomize.io/){ target="_blank" }
- [Mozilla SOPS](https://github.com/getsops/sops){ target="_blank" }

## Troubleshooting

If you hit an issue during the labs:

```bash
# What failed?
flux get all

# What's the error?
kubectl describe kustomization <name> -n flux-system

# What happened?
flux events --for kustomization/<name>

# Why?
kubectl logs -n flux-system deploy/kustomize-controller
```

If none of that helps, raise your hand.

## After the Workshop

- [The 10 Landmines Between Your GitOps Workshop and Production](https://guides.platformfix.com/gitops-10-landmines){ target="_blank" }: Free guide with the 25-question readiness audit
- [Book a Platform Review](https://calendly.com/platformfixer/devops-pro){ target="_blank" }: 30 minutes. You describe your stack. I tell you what I'd delete first.
- [The Deletion Digest](https://newsletter.platformfix.com){ target="_blank" }: Weekly newsletter. One idea, no fluff.
