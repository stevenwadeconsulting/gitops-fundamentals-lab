# Resources

## Documentation

- [Flux Documentation](https://fluxcd.io/flux/){ target="_blank" }
- [Flux Operator Documentation](https://fluxoperator.dev/){ target="_blank" }
- [OpenGitOps Principles](https://opengitops.dev/){ target="_blank" }
- [Kustomize Documentation](https://kustomize.io/){ target="_blank" }
- [Mozilla SOPS](https://github.com/getsops/sops){ target="_blank" }

## Industry Research

Use these reports to build the business case for GitOps at your organisation.

- [CNCF Annual Survey 2024](https://www.cncf.io/reports/cncf-annual-survey-2024/){ target="_blank" }: Cloud-native adoption trends, GitOps adoption rates
- [2025 DORA Report](https://dora.dev/research/2025/){ target="_blank" }: Deployment frequency, lead time, MTTR, change failure rate, and the first measurement of AI's impact on delivery performance
- [Komodor 2025 Enterprise Kubernetes Report](https://komodor.com/blog/komodor-2025-enterprise-kubernetes-report-finds-nearly-80-of-production-outages/){ target="_blank" }: 80% of outages from recent changes, 34 workdays/year lost to troubleshooting
- [GitOps in 2025 (CNCF Blog)](https://www.cncf.io/blog/2025/06/09/gitops-in-2025-from-old-school-updates-to-the-modern-way/){ target="_blank" }: The shift from push-based to pull-based operations

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

## Steve's Other Sessions at DevOps Pro Europe

| Session | When | Where |
|---------|------|-------|
| [The Killer Question: How One Sentence Can Transform Your Engineering Career](https://events.pinetool.ai/3574/#sessions/112181?referrer%5Bpathname%5D=%2Fspeakers%2F1018504&referrer%5Bsearch%5D=%3Freferrer%255Bpathname%255D%3D%252Fspeakers%26referrer%255Bsearch%255D%3D%26referrer%255Btitle%255D%3DSpeakers&referrer%5Btitle%5D=Speaker){ target="_blank" } | Thursday 21 May, 11:05 EEST | Hall 1 |
| [Panel: Humans Before Pipelines](https://events.pinetool.ai/3574/#sessions/115044?referrer%5Bpathname%5D=%2Fspeakers%2F1018504&referrer%5Bsearch%5D=%3Freferrer%255Bpathname%255D%3D%252Fspeakers%26referrer%255Bsearch%255D%3D%26referrer%255Btitle%255D%3DSpeakers&referrer%5Btitle%5D=Speaker){ target="_blank" } | Thursday 21 May, 15:05 EEST | Hall 5 |

!!! tip "Thursday morning"
    The Killer Question talk covers the communication skills that help you get GitOps adopted at your organisation. Everything you learned today gives you the technical skills. Thursday gives you the words to sell it internally. Come ready to stand up.

[View all Steve's sessions](https://events.pinetool.ai/3574/#speakers/1018504){ target="_blank" }

---

## After the Workshop

- [The 10 Landmines Between Your GitOps Workshop and Production](https://guides.platformfix.com/gitops-10-landmines){ target="_blank" }: Free guide with the 25-question readiness audit
- [Book a Platform Review](https://calendly.com/platformfixer/devops-pro){ target="_blank" }: 30 minutes. You describe your stack. I tell you what I'd delete first.
- [The Deletion Digest](https://newsletter.platformfix.com){ target="_blank" }: Weekly newsletter. One idea, no fluff.
