/*  

Tool to delete (texture) files that are not assigned to any material in the project

by: Laura Koekoek | laurakoekoek91@gmail.com

*/

-- to pass variables between UI rollouts
global varDump ( 
	struct varDumpStruct(folder,format,delFolders)
	varDump = varDumpStruct()
)

-- get all the files in folder
function getAllFolderFiles directory formatInput = (
	dirs = getDirectories directory
	files = #()
	
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
		tempFiles = getFiles (d + "*." + formatInput)
		
		for p in tempFiles do (
			append files p
		)
	)
	return files
)

-- get all texture files in max project
function getAllTextureFiles inputMaterials = (
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

-- delete unused files
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

	for f in removeFiles do (
		print "removed file: "
		print f
		deleteFile f
	)
)

-- delete empty folders
function delFolders pathInput = (
	dir_array = GetDirectories (varDump.folder +"/*")
	
	-- append subdirectories (1 depth)
	for d in dir_array do (
		dTemp = substituteString d "\\" "\\\\"
		subdirs = getDirectories (dTemp + "*")	
		for sd in subdirs do (
			append dir_array sd
		)
	)
	
	for d in dir_array do (
		folderEmpty = (getEmptyFolders d)
		if (folderEmpty == true ) then (
			print "deleting empty folder:"
			print d
			str = "rmDir " + (d as string)
			hiddendoscommand str startpath:"$max" exitCode:&exitcode
		)
	)
)

-- get list of empty folders
function getEmptyFolders directory = (
	dirs = getDirectories directory
	d = directory

	dTemp = substituteString d "\\" "\\\\"
	tempFiles = getFiles (d + "*")
	
	folderEmpty = false
	if (tempFiles.count < 1) then (
		if (dirs.count < 1) then (
			folderEmpty = true
		)
	)
	return folderEmpty
)

-- Confirm the files to delete dialog
rollout confirmRollout "Are you sure?"  width:350
(
	label lab1 "Delete all unused "
	label lab2 varDump.format
	label lab3 "files in folder:"
	label lab4 varDump.folder

	button deleteBtn1 "Delete" width:220 height:60
	on deleteBtn1 pressed do (
		outputFolder = substituteString varDump.folder "\\" "\\\\"
		outputFolder = (outputFolder + "\\")
		delFiles outputFolder varDump.format
		
		if (varDump.delFolders == true) then (
			delFolders outputFolder
		)
		
		destroydialog confirmRollout
		destroydialog mainRollout
		messageBox "Done! View log for details"
	)
)

-- Main ui function
rollout mainRollout "Delete unused texture files" width:240
(
	-- browse for root folder
	group "Texture Root Folder" (
		editText destFolderPath  readonly:false pos:[10,30] width:195 height:20
		button setFolderPath "..."  pos:[210,30] width:20 height:20
	)
	on setFolderPath pressed do (
		destFolderPath.text = getSavePath "Output Folder:"	
	)
	-- file format option
	group "Texture format" (
		checkbox delOtherFilesCheck "Accept any format" checked:false tooltip:"Check to run the check for any file format"
		editText formatInput readonly:false  width:55 height:20 text:"PNG" tooltip:"File format to check"
	)
	-- Option to also delete empty subfolders
	group "Options" (
		checkbox delFoldersCheck "Delete empty subfolders" checked:false tooltip:"Also delete any empty folders"
	)
	on delOtherFilesCheck changed theState do (
		if (theState == true) then (
			formatInput.enabled = false
		)
		else(
			formatInput.enabled = true
		)
	)
	-- Button to run the script
	button deleteBtn "Delete unused textures" width:220 height:60
	
	on deleteBtn pressed do (
		varDump.format = formatInput.text
		if (delOtherFilesCheck.state == true) then (
			varDump.format = "*"
		)
		varDump.folder = destFolderPath.text
		varDump.delFolders = delFoldersCheck.state
		
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
createdialog mainRollout