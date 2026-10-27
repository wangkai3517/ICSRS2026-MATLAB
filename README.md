# MATLAB 论文代码

环境：MATLAB R2021a 或更新版本；求解使用 Gurobi 或 Optimization Toolbox 的 `linprog`。

在 MATLAB 中进入本目录，按需运行：

```matlab
main1_single_optimization
main2_guarantee_frontier
main3_rho_sensitivity
```

三个程序可独立运行。结果保存到 `results/`，图片保存到 `figures/`。
单独运行 `plot_fig*.m` 可读取已有结果绘图；传入 `'frozen'` 使用冻结结果。

## 文件用途

| 文件 | 用途 |
| --- | --- |
| `main1_single_optimization.m` | 求解各方案及 D–W 分解，生成表 II 和图 1、2、4、5。 |
| `main2_guarantee_frontier.m` | 计算共同保障前沿，生成图 3。 |
| `main3_rho_sensitivity.m` | 分析模糊集半径的影响，生成表 III。 |
| `plot_fig1_network.m` | 绘制电水网络和 IR+ 保护配置。 |
| `plot_fig2_policy_risk.m` | 绘制各方案的系统韧性和两网改善。 |
| `plot_fig3_guarantee_frontier.m` | 绘制共同保障下限与系统韧性的关系。 |
| `plot_fig4_protection_changes.m` | 绘制 IR+ 相对基本 DRO 的保护水平变化。 |
| `plot_fig5_dw_bounds.m` | 绘制 IR+ 分解算法的上下界。 |
| `lib/paper_arrow.m` | 绘制网络中的有向链路。 |
| `lib/paper_axes.m` | 设置坐标轴样式。 |
| `lib/paper_case.m` | 读取并校验 RED40 算例。 |
| `lib/paper_check_reference.m` | 将目标值与冻结结果比对。 |
| `lib/paper_config.m` | 设置求解参数和结果目录。 |
| `lib/paper_export.m` | 导出 PDF 和 PNG 图片。 |
| `lib/paper_figure.m` | 创建指定尺寸的图窗。 |
| `lib/paper_grid_coords.m` | 将节点坐标对齐到网格。 |
| `lib/paper_load_results.m` | 读取运行结果或冻结结果供绘图使用。 |
| `lib/paper_policy_table.m` | 生成表 II，导出 CSV 和 LaTeX。 |
| `lib/paper_root.m` | 获取代码根目录。 |
| `lib/paper_run_dw.m` | 运行 D–W 分解并恢复、检查方案。 |
| `lib/paper_split.m` | 将集中式解拆为各网络的方案。 |
| `lib/paper_style.m` | 设置绘图字体、配色和字号。 |
| `lib/paper_tex_num.m` | 格式化 LaTeX 表格中的数字。 |
| `lib/r40_backend.m` | 选择 Gurobi 或 linprog 求解器。 |
| `lib/r40_dw.m` | 执行 D–W 主问题协调和列生成。 |
| `lib/r40_lp.m` | 构造、求解线性规划并评价方案。 |
| `lib/r40_owner.m` | 处理各网络的本地定价和方案恢复。 |
| `lib/r40_selftest.m` | 检查求解器对偶符号和风险计算。 |

## 数据与输出

| 文件或目录 | 用途 |
| --- | --- |
| `inputs/MODEL_RED40.mat` | RED40 模型、情景、概率和基准方案。 |
| `inputs/FROZEN_IDENTITY.json` | 算例指纹和情景编号，用于校验输入。 |
| `inputs/RED40_SP_reduced.mat` | SP 目标值参考。 |
| `inputs/RED40_SYS_reduced.mat` | 基本 DRO 目标值参考。 |
| `inputs/RED40_IR0_reduced.mat` | IR0 目标值参考。 |
| `inputs/RED40_IRpos_reduced.mat` | IR+ 目标值参考。 |
| `results/frozen/FINAL_RESULTS.mat` | 已保存的论文结果，供直接绘图使用。 |
| `figures/` | 生成的 PDF 和 PNG 图片。 |
