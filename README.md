# Dev-Ops ecosystem
![Animation](/docs/DevOpsEcosystem.gif)

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
* setting up system automation foundation
* automating tasks that were part of the end-to-end process
* orchestrating overall process, and 
* continuous improvement or iterative & incremental implementation

System Automation foundation enables tasks to be done, carry out on the right place.  Tasks automation involves developing command line interface for the  individual tasks of the end-to-end process.  Overall process orchestration connects the tasks of an end-to-end process into a logical orchestrated flow, ensures tasks are carried out in the right sequence, and provides turn-key operational triggers such as: started when code commit, or by system's schedulers or as a self-served button
 
The construction involves studying current practice of the end-to-end process to be automated, understanding existing system automation foundation, and boundary conditions, etc.  This usually involves working with the stakeholders, domain experts, reading system's design & operational documentations, and fitting into the company's IT & security policies.

The result is a highlevel process flow mapping and implementation strategy to guide continuous process improvement or iteratively incremental implementation 
