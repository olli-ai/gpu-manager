# GPU Manager

This is a fork from https://github.com/tkestack/gpu-manager to be deployed with Jenkins-X. The dockerfile has been totally changed for a clearer deployment.

All the changes are related to the way it is deployed.

Only the nodes matching [`nodeSelector`](./charts/gpu-manager/values.yaml) are affected.

`gpu-manager` creates a device plugin on each node for the `tencent.com/vcuda-core` and `tencent.com/vcuda-memory` resources. It requires NVidia drivers to be installed on the node, using [GKE's `nvidia-driver-installer`](https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml) as init-container. It will then mount cuda libraries in the containers to make them available. `libcuda` and `libnvidia-ml` libraries are replaced by [`libcuda-controller`](https://github.com/olli-ai/vcuda-controller) in order to ensure memory and GPU limits. It expects pods to have been scheduled by [`gpu-admission`](https://github.com/olli-ai/gpu-admission).

`gpu-client` is called by [`libcuda-controller`](https://github.com/olli-ai/vcuda-controller), and will request `gpu-manager` to create the configuration files in `/etc/nvidia`. Those configuration files are used to limit memory and GPU.

## How to deploy a cuda pod

Docker images must NOT include the cuda libraries. Those will be mounted by `gpu-manager`. Containers that intend to use cuda must defines the requests and limites `tencent.com/vcuda-core` and `tencent.com/vcuda-memory`:
- `tencent.com/vcuda-core` is the percentage of GPU usage required (maximum 100%). A typical tensorflow exemple does not seem to use more than 20%
- `tencent.com/vcuda-memory` is the number of 256MB pages of GPU memory requested. A Testla T4 GPU seems to provide 58 pages.

```yaml
    resources:
      requests:
        cpu: 700m
        memory: 2Gi
        tencent.com/vcuda-core: 20
        tencent.com/vcuda-memory: 10
      limits:
        cpu: 700m
        memory: 2Gi
        tencent.com/vcuda-core: 20
        tencent.com/vcuda-memory: 10
```

In order to be scheduled by [`gpu-admission`](https://github.com/olli-ai/gpu-admission), pods must include a `schedulerName`, and `tolerations` to run on GPU servers.

```yaml
  schedulerName: gpu-scheduler
  tolerations:
  - key: nvidia.com/gpu
    operator: Equal
    value: present
    effect: NoSchedule
```

Some examples:
- [`tensorflow.yaml`](./tensorflow.yaml)
- [`tensorflow-dep.yaml`](./tensorflow-dep.yaml)
