# GitHub 上传权限

权限范围只需 `Petrichor12310/compile-prepare`。

| 权限 | 用途 | 是否需要 |
| --- | --- | --- |
| Contents: Read and write | 上传源代码、文档、验证证据和创建分支 | 需要 |
| Workflows: Read and write | 上传 `.github/workflows/verify.yml` | 上传现有 CI 配置时需要 |
| Pull requests: Read and write | 创建和更新 PR | 使用 PR 协作时需要 |
| Actions: Read | 查看 CI 状态和日志 | 可选 |
| Metadata: Read | 仓库元数据 | GitHub 自动提供 |

不用授予 Administration、组织管理、Secrets 或所有仓库的访问权限。

截至 2026-10-03，连接读取到仓库的 `push=true`，但此前创建文件返回
`403 Resource not accessible by integration`。用户的仓库写入权限和 GitHub App
的安装授权是两个独立条件；当前证据还不能确定是 App 权限缺失还是安装范围未覆盖该仓库。

由仓库所属账号在 GitHub 的 Settings → Applications → Installed GitHub Apps
中找到当前连接对应的 App，点击 Configure，确认 Only select repositories 包含本仓库。
再检查 App 的 Contents/Workflows 权限及待批准的权限更新。安装者只能接受 App
请求的权限，不能给第三方 App 自行添加未请求的权限。

若 App 本身不支持写入，可在本机 Git 客户端配置有上述权限的凭据，然后从本地仓库推送。
不要把 PAT、密码或私钥贴到聊天或提交到项目。仅修复代码并在本地验证不需要 GitHub 写权限。

参考：

- [创建或更新文件所需权限](https://docs.github.com/en/rest/repos/contents#create-or-update-file-contents)
- [检查安装权限及仓库范围](https://docs.github.com/en/apps/using-github-apps/reviewing-and-modifying-installed-github-apps)
- [批准 App 权限更新](https://docs.github.com/en/apps/using-github-apps/approving-updated-permissions-for-a-github-app)
