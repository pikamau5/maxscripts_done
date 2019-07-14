/*  

Tool to delete (texture) files that are not assigned to any material in the project

by: Laura Koekoek | laurakoekoek91@gmail.com

*/


global varDump ( -- to pass variables between UI rollouts
	struct varDumpStruct(folder,format)
	varDump = varDumpStruct()
)

function getAllFolderFiles directory formatInput = (

	dirs = getDirectories directory
	pngs = #()

	-- append subdirectories (1 depth)
	for d in dirs do (
		dTemp = substituteString d "\\" "\\\\"
		subdirs = getDirectories (dTemp + "*")
		
		for sd in subdirs do (
			append dirs sd
		)
	)

	-- put all files in files array
	for d in dirs do (
		dTemp = substituteString d "\\" "\\\\"
		tempPngs = getFiles (d + "*." + formatInput)
		
		for p in tempPngs do (
			append pngs p
		)
	)
	return pngs
)

function getAllTextureFiles inputMaterials =
(
	local allTextureFiles = #()
	for eachMat in inputMaterials do
	(
		format "-- Material: %\n" eachMat.name;
		for i = 1 to (getNumSubTexmaps eachMat) do
		(
			try (if (getNumSubTexmaps (getSubTexmap eachMat i)) != 0 then
			(
				join allTextureFiles (getAllTextureFiles #((getSubTexmap eachMat i)))
			)
			) catch ()
			if (isProperty (getSubTexmap eachMat i) #filename) then
			(
				append allTextureFiles (getSubTexmap eachMat i)
				--format "---- TextureFile: \"%\"\n" (getSubTexmap eachMat i).filename;
			)
		)
	)
	
	sceneFileNames = #()
	
	for p in allTextureFiles do (
		append sceneFileNames p.filename
	)
	
	return sceneFileNames;
)


function delFiles pathInput formatInput =
(
	allSceneFiles = (getAllTextureFiles sceneMaterials);

	-- change this to "browse for root"
	pathInput = pathInput + "\\*"
	allFolderFiles = (getAllFolderFiles pathInput formatInput)
	print pathInput

	--print "ALL SCENE FILES"
	for p in allSceneFiles do 
	(
		if (p != undefined) do (
			p = filenameFromPath p
		)
		--print p
		)

	allFolderFilesRelative = #()
		
	--print "ALL FOLDER FILES"
	for i = 1 to allFolderFiles.count do (
			allFolderFilesRelative[i] = allFolderFiles[i]
			if (allFolderFiles[i] != undefined) do (
			allFolderFilesRelative[i] = filenameFromPath allFolderFiles[i]
			--print allFolderFilesRelative[i]
			)
		)

	removeFiles = #()

	print ("RemoveFiles.count = " + removeFiles.count as string)

	-- do comparison
	for i = 1 to allFolderFiles.count do (
	fileExists = false
		for sf in allSceneFiles do (
			
			--print "SF: " + sf as string
			if (sf != undefined) do (
				sf = filenameFromPath sf
			
			)
			
			if (allFolderFilesRelative[i] == sf) do (
				print ("This file is used in scene: " + sf)
				fileExists = true
				
			)
		)
		if (fileExists == false) do (	
			append removeFiles allFolderFiles[i]
		)
	)

	print ("RemoveFiles.count = " + removeFiles.count as string)
	print "files removed: "

	for f in removeFiles do (
		print f
		deleteFile f
	)
)

rollout mainRollout "Delete unused texture files" width:240
(
	-- root folder
	group "Texture Root Folder" (
		editText destFolderPath  readonly:false pos:[10,30] width:195 height:20
		button setFolderPath "..."  pos:[210,30] width:20 height:20

	)

	on setFolderPath pressed do (
		destFolderPath.text = getSavePath "Output Folder:"	
	)
	-- file format
	
		group "Texture format" (
		editText formatInput readonly:false  width:55 height:20 text:"PNG"
	)
	
	button deleteBtn "Delete unused textures" width:220 height:60
	on deleteBtn pressed do (
		
		varDump.folder = destFolderPath.text
		varDump.format = formatInput.text
		
		-- some basic checks for user error
		if (destFolderPath.text == "") then (
			messageBox "Select a folder"
		)
		else if (formatInput.text == "") then (
			messageBox "Select a file format"
		)
		else(
			createdialog confirmRollout	
		)	
	)
)

rollout confirmRollout "Are you sure?"  width:240
(
	label lab1 "Delete all unused"
	label lab2 varDump.format
	label lab3 "files in folder:"
	label lab4 varDump.folder

	button deleteBtn1 "Delete" width:220 height:60
	on deleteBtn1 pressed do (
		
		outputFolder = substituteString varDump.folder "\\" "\\\\"
		outputFolder = (outputFolder + "\\")
		
		delFiles outputFolder varDump.format
		destroydialog confirmRollout
		destroydialog mainRollout
		
		messageBox "Done! View log for details"

	)
)

createdialog mainRollout