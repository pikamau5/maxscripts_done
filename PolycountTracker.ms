/*

List polycount + object list


*/

objArray = #()

function listPolys =
(
	-- collect all objects in the selection
	local objs = for obj in selection collect obj
	
	-- store number of objects
	local objsCount = objs.count
	
	-- get number of polys for all objects
	local polys = for obj in objs collect (getPolygonCount obj)[1]
	
	-- generate index array for sorting
	local sortIndices = for i = 1 to objsCount collect i
	
	-- sort
	fn sortByPolycount a b arr: =(
		case of(
			(arr[a] > arr[b]): -1
			(arr[a] < arr[b]): 1
			default: 0
		)
	)
	
	-- sort by number of polys
	qSort sortIndices sortByPolycount arr:polys

	-- output stats to the listener
	--clearListener()
	-- format "/*\n\tPolycounts for scene \"%\" (% objects)\n\tNumber of poly's range from % to %\n\t-----------------------------------------------\n*/\n\n" maxFileName objsCount polys[sortIndices[sortIndices.count]] polys[sortIndices[1]]
	
	-- clear arrays
	printArray = #()
	objArray = #()
	printLine = ""
	
	for i in sortIndices do (
		-- line to add to listbox
		printLine =  polys[i] as string + " -- " + objs[i].name as string
		append printArray printLine
		-- save corresponding object for selection
		append objArray objs[i] 
	)
	return printArray
)

rollout MainRollout "Polycount tracker" width:280
(
	group "Top polycounts" (
		MultiListBox listbox items:#("Click refresh to create list") height:35

		-- select objects from list
		on listbox selectionEnd do (
			max select none
			for lb in listbox.selection do (
				selectmore objArray[lb]
			)
		)
		button btn "Refresh"
	)
	on btn pressed do(
		listbox.items = listPolys()
	)	
)
createdialog mainRollout