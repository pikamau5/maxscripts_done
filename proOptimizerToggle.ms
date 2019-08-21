/* Tool to enable / disable ProOptimizer for all scene objects */

fn getObjsUsingMod objs mod =
(
	for o in objs where ((findItem (for m in o.modifiers collect classOf m) mod) > 0)collect o
)
modifierName = ProOptimizer
function SelectModObjs =
	(
	objectArr = getObjsUsingMod $objects modifierName
	select objectArr
	)
rollout MainRollout "ProOptimizerTool" width:170
(
	group "Actions" (
		button btnCreate "Select objs with ProOptimizer" width:(mainRollout.width - 30) enabled:true
		button btnDisable "Disable all" width:(mainRollout.width-30) enabled:true
		button btnEnable "Enable all" width:(mainRollout.width-30) enabled:true
		button btnCollapse "Collapse stacks with ProOptimizer! (NO UNDO)" width:(mainRollout.width-30) enabled:true	
	)
	on btnCreate pressed do (
		SelectModObjs()
	)
	on btnDisable pressed do (
		(getClassInstances proOptimizer).enabled=false
	)
	on btnEnable pressed do (
		(getClassInstances proOptimizer).enabled=true
		SelectModObjs()
		for o in selection do (
			o.modifiers[#ProOptimizer].Calculate = on
		)
	)
	on btnCollapse pressed do (
		(getClassInstances proOptimizer).enabled=true
		SelectModObjs()
		for o in selection do (
			o.modifiers[#ProOptimizer].Calculate = on
			collapseStack o
		)
	)
)
createdialog mainRollout