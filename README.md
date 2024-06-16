# Dev-Ops ecosystem
![Animated Dev-Ops ecosystem](/docs/DevOpsEcosystem.gif)

# Common patterns
Everything seems to be reducible to end-to-end process automation
* applications - build, deployment, test, release, CICD = build + deployment + test + release, ...
* environments/infrastructure - provision, configure, re-baseline, healthcheck, monitor, ....
* system operational tasks - services stop/start/restart/monitor, data import/export/extract,....
* ....

## Challenge
Automate end to end processes 
## Goals:
Improve velocity, repeatability, efficiency, and resiliency of the end to end processes
## Conceptual solution
4 key tasks for forming an end-to-end process automation from the ground up: 
1. setting up system automation foundation
2. automating tasks that were part of the end-to-end process
3. orchestrating overall process, and 
4. continuous improvement or iterative & incremental implementation

System Automation foundation enables tasks to be done, carried out in the right place. 

Task automation involves developing a command line interface for the individual tasks of the end-to-end process. 

Overall process orchestration connects the tasks of an end-to-end process into a logical orchestrated flow, ensures tasks are carried out in the right sequence, and provides turn-key operational triggers such as: started when code commit, or by system's schedulers or as a self-served button

## Implementation Approach
1. Mastering current practice of the end-to-end process to be automated, understanding existing system automation foundation, and boundary conditions (e.g. IT security policies/compliances), etc. This usually involves working with the stakeholders, domain experts, reading system's design & operational documentations. 
2. Deriving/designing a high level process flow mapping and implementation strategy to guide continuous process improvement or iteratively incremental implementation 
3. start implementing tasks, iteratively releasing/introducing the MVP to the stakeholders/users 
