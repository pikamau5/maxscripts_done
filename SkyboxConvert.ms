-- skybox cylindrical/cubemap converter
-- created this script kinda for learning maxscript
-- the target is to create a script you can drop in an empty scene and it will render the images to file.

-- FUTURE IMPROVEMENTS: USER SET REOLUTION, CUBE TO SPHERE

-- user should set these
renderSize = 128
outputFolder = ""
skySphereTexPath = ""
fileFormat = ""

sceneIsClear = false

-- Rotations -- these will add up!!
down_rot = eulerangles 0 0 0
front_rot = eulerangles 90 0 0
left_rot = eulerangles 90 0 90
right_rot = eulerangles 90 0 -90
back_rot = eulerangles 90 0 180
up_rot = eulerangles 180 0 0

fn ClearScene = (

	select $*
	delete selection
	
	-- create cameras
	downCam = freecamera()
	frontCam = freecamera()
	leftCam = freecamera()
	rightCam = freecamera()
	backCam = freecamera()
	upCam = freecamera()

	-- give them names
	downCam.name = "Down"
	frontCam.name = "Front"
	leftCam.name = "Left"
	rightCam.name = "Right"
	backCam.name = "Back"
	upCam.name = "Up"

	--rotate cameras
	rotate $Front front_rot
	rotate $Left left_rot
	rotate $right right_rot
	rotate $Back back_rot
	rotate $Up up_rot

	-- put cameras in an array
	camArray = #()
	camArray.count = 6
	camArray[1] = getnodebyname "Down"
	camArray[2] = getnodebyname "Front"
	camArray[3] = getnodebyname "Left"
	camArray[4] = getnodebyname "Right"
	camArray[5] = getnodebyname "Back"
	camArray[6] = getnodebyname "Up"

	-- set fov to 90
	for i = 1 to camArray.count do (
		camArray[i].fov = 90
	)

	
	
	sceneIsClear = true
)

fn SphereToCube = (

-- ### SPHERE TO CUBE ###

	-- create a sphere with flipped normals
	skySphere = sphere()
	skySphere.name = "SkySphere"
	skySphere.segs = 128
	skySphere.radius = 100
	skySphere.mapCoords = true
	addmodifier skySphere (NormalModifier flip:on)

	-- create a material for sphere (add ui to choose tex file for this)
	skySphereMat = StandardMaterial()
	skySphereMat.name = "SkySphereMaterial"
	skySphere.material = skySphereMat
	skySphereMat.showInViewport = true
	skySphereMat.selfIllumAmount = 100

	--bring in the texture map
	skySphereBitmap = bitmaptexture filename:skySphereTexPath
	skySphereMat.diffusemap = skySphereBitmap -- assign to diffuse slot
	skySphereBitmap.name = "SkyboxCubemapTexture"

	-- configure render settings
	renderWidth = renderSize
	renderHeight = renderSize

	-- render! :)
	print "Rendering textures..."
	Render camera:$Back outputfile: (outputFolder + "back." + fileFormat)
	Render camera:$Down outputfile: (outputFolder + "down." + fileFormat)
	Render camera:$Front outputfile: (outputFolder + "front." + fileFormat)
	Render camera:$Left outputfile: (outputFolder + "left." + fileFormat)
	Render camera:$Right outputfile: (outputFolder + "right." + fileFormat)
	Render camera:$Up outputfile: (outputFolder + "up." + fileFormat)
	print ("Rendered files to " + outputFolder)
)

fn CubeToSphere = (

	-- create planes
	planeLeft = plane()
	planeRight = plane()
	planeBack = plane()
	planeDown = plane()
	planeUp = plane()
	planeFront = plane()
	
	planeLeft.name = "PlaneLeft"	
	planeRight.name = "PlaneRight"
	planeBack.name = "PlaneBack"
	planeDown.name = "PlaneDown"
	planeUp.name = "PlaneUp"
	planeFront.name = "PlaneFront"
	
	
	rotate $PlaneLeft left_rot
	rotate $PlaneRight right_rot
	rotate $PlaneUp up_rot
	rotate $PlaneDown down_rot
	rotate $PlaneBack back_rot
	rotate $PlaneFront front_rot
	
		-- put planes in an array
	planeArray = #()
	planeArray.count = 6
	planeArray[1] = getnodebyname "PlaneDown"
	planeArray[2] = getnodebyname "PlaneFront"
	planeArray[3] = getnodebyname "PlaneLeft"
	planeArray[4] = getnodebyname "PlaneRight"
	planeArray[5] = getnodebyname "PlaneBack"
	planeArray[6] = getnodebyname "PlaneUp"
	

	-- offset planes
	for i = 1 to planeArray.count do (
		in coordsys #local planeArray[i].pos.z = -10
		planeArray[i].width = 20
		planeArray[i].length = 20
	)
	
	-- create materials
	cubeMatFront = StandardMaterial()
	cubeMatLeft = StandardMaterial()
	cubeMatRight = StandardMaterial()
	cubeMatUp = StandardMaterial()
	cubeMatDown = StandardMaterial()
	cubeMatBack = StandardMaterial()
	
	cubeMatFront.name = "cubeMaterialFront"
	cubeMatLeft.name = "cubeMaterialLeft"
	cubeMatRight.name = "cubeMaterialRight"
	cubeMatUp.name = "cubeMaterialUp"
	cubeMatDown.name = "cubeMaterialDown"
	cubeMatBack.name = "cubeMaterialBack"
	
	PlaneDown.material = cubeMatDown
	PlaneUp.material = cubeMatUp
	PlaneLeft.material = cubeMatLeft
	PlaneRight.material = cubeMatRight
	PlaneFront.material = cubeMatFront
	PlaneBack.material = cubeMatBack
	
	cubeMatFront.showInViewport = true
	cubeMatLeft.showInViewport = true
	cubeMatRight.showInViewport = true
	cubeMatUp.showInViewport = true
	cubeMatDown.showInViewport = true
	cubeMatBack.showInViewport = true
	
	cubeMatFront.selfIllumAmount = 100
	cubeMatLeft.selfIllumAmount = 100
	cubeMatRight.selfIllumAmount = 100
	cubeMatUp.selfIllumAmount = 100
	cubeMatDown.selfIllumAmount = 100
	cubeMatBack.selfIllumAmount = 100
	
	-- assign bitmaps
	cubeLeftBitmap = bitmaptexture filename:(outputFolder + "left.png")
	cubeMatLeft.diffusemap = cubeLeftBitmap
	
	cubeRightBitmap = bitmaptexture filename:(outputFolder + "right.png")
	cubeMatRight.diffusemap = cubeRightBitmap
	
	cubeDownBitmap = bitmaptexture filename:(outputFolder + "down.png")
	cubeMatDown.diffusemap = cubeDownBitmap
	
	cubeUpBitmap = bitmaptexture filename:(outputFolder + "up.png")
	cubeMatUp.diffusemap = cubeUpBitmap
	
	cubeFrontBitmap = bitmaptexture filename:(outputFolder + "front.png")
	cubeMatFront.diffusemap = cubeFrontBitmap
	
	cubeBackBitmap = bitmaptexture filename:(outputFolder + "back.png")
	cubeMatBack.diffusemap = cubeBackBitmap
	
	-- create sphere
	projectionSphere = sphere()
	
	projectionSphere.name = "ProjectionSphere"
	projectionSphere.segs = 128
	projectionSphere.radius = 9
	projectionSphere.mapCoords = true
	addmodifier projectionSphere (Projection cage:on pushValue:10.0)
	
	a = #($planeDown, $planeUp,$planeLeft,$planeRight,$planeFront,$planeBack)
	addPModObjects projectionSphere false true objList:a
	
	select $projectionSphere
	
	$.Projection.pushCage(10.0)
	
	be1 = diffusemap()
	be1.outputSzX = be1.outputSzY = 1024
	be1.enabled = true
	be1.fileName = "C:\\Users\\lkoekoek\\Desktop\\test\\TESTFILE.png" -- this is not working?
	be1.fileType = ".png"
	
	projectionSphere.INodeBakeProjProperties.enabled = true
	projectionSphere.INodeBakeProperties.bakeEnabled = true -- ?
	projectionSphere.INodeBakeProperties.bakeChannel = 1 -- ?
	
	projectionSphere.INodeBakeProperties.addBakeElement be1 
	
	render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[1024,1024] -- only renders after manually clicking render once in rtt (?)

	--render rendertype:#bakeSelected

	
	-- create sphere with uvmap
	-- add projection modifier
	-- render to texture
		-- diffusemap
		-- projection on
		-- resolution (2:1)
	
)

--#### CUBE TO SPHERE #### -- no cameras needed here........

-- create a cube
	-- create a multisub material

-- create a sphere

rollout initRollout "Skybox conversion" width:240
(
	label lbl2 "Drop this script into a new maxfile."	
	button toCubeBtn "Cylindrical map -> Cubemap" width:220 height:60
	button toCylinderBtn "Cubemap -> Cylindrical map" width:220 height:60

	
	on toCubeBtn pressed do (
		createdialog toCubeRollout
		destroydialog initRollout
	)
	on toCylinderBtn pressed do (
		createdialog toCylinderRollout
		destroydialog initRollout
		)	
)
rollout toCubeRollout "Cylindrical to Cube" width:200
(	
group "Input (Cylindrical texture map)" (
		editText sourceSkyboxPath readonly:false pos:[10,20] width:155 height:20 -- should it be read only?
		button setSkyboxPath "..." pos:[170,20] width:20 height:20
		
		--button DirLookUp "..." pos:[160,48] width:16 height:20 --just ref
	)
	label lb210 "\n"
	group "Output Format" (
		editText formatInput readonly:false  width:155 height:20 text:"PNG"
	)
	group "Output Resolution" (
		spinner resInput range:[-9999,9999,1024] type:#integer
	)
		
	
	group "Output Folder" (
		editText destFolderPath  readonly:false pos:[10,180] width:155 height:20
		button setFolderPath "..."  pos:[170,180] width:20 height:20
	)
	

	
	button startRender "Convert" width:180 height:40
	
	label lbl0 "by lauuura"
	
	on clearSceneBtn pressed do (
		if (queryBox "This will clear the scene and create new render setup." beep:false) then ClearScene()
	)
	
	on setFolderPath pressed do (
		destFolderPath.text = getSavePath "Output Folder:"
		outputFolder = substituteString destFolderPath.text "\\" "\\\\"
		outputFolder = (outputFolder + "\\")
	)
	
	on setSkyboxPath pressed do (
		sourceSkyboxPath.text = getOpenFileName "File:"
		skySphereTexPath = substituteString sourceSkyboxPath.text "\\" "\\\\"
	)
	
	on startRender pressed do (
		if (skySphereTexPath == "" or outputFolder == "") then
		(
			messagebox("Set the paths!")
		)
		else
		(	
			fileFormat = formatInput.text
			ClearScene()
			SphereToCube()
			messagebox("Done!")
			--doscommand testFolder2 --trying to open explorer window
		)
	)

)


rollout toCylinderRollout "Cube to Cylindrical" width:200
(				
	group "Input (Cubemap folder)" (
		editText destFolderPath  readonly:false pos:[10,20] width:155 height:20
		button setFolderPath "..."  pos:[170,20] width:20 height:20
	)
	label lbl7 "\n"
		group "Output Format" (
		editText formatInput readonly:false pos:[10,90] width:155 height:20 text:"PNG"
	)




	group "Cylindrical map output path" ( -- group "Sphere skybox texture" 
		editText sourceSkyboxPath readonly:false pos:[10,140] width:155 height:20 -- should it be read only?
		button setSkyboxPath "..." pos:[170,140] width:20 height:20
	)


	
	button startRenderTexture "Convert" width:180 height:40
	
	label lbl0 "by lauuura"
	
	on clearSceneBtn pressed do (
		if (queryBox "This will clear the scene and create new render setup." beep:false) then ClearScene()
	)
	
	on setFolderPath pressed do (
		destFolderPath.text = getSavePath "Output Folder:"
		outputFolder = substituteString destFolderPath.text "\\" "\\\\"
		outputFolder = (outputFolder + "\\")
	)
	
	on setSkyboxPath pressed do (
		sourceSkyboxPath.text = getOpenFileName "File:"
		skySphereTexPath = substituteString sourceSkyboxPath.text "\\" "\\\\"
	)
	
	
	on startRenderTexture pressed do (
	
	fileFormat = formatInput.text
	ClearScene()
	CubeToSphere()
	)
)

createdialog initRollout