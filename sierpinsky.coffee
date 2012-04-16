T = THREE

camera = undefined
scene = undefined
renderer = undefined
mesh = undefined

midpoint = (a,b) ->
  a = a.position
  b = b.position
  new T.Vector3 (b.x+a.x)/2, (b.y + a.y)/2, (b.z + a.z)/2

triangleFaces = (vertexIndices) ->
  faceIndices =
    [[0, 1, 3],
     [1, 2, 3],
     [0, 3, 2],
     [0, 2, 1]]

  faces = []
  for [f0,f1,f2] in faceIndices
    faces.push new T.Face3(
      vertexIndices[f0],
      vertexIndices[f1],
      vertexIndices[f2])
  faces

subdivide = (geom, facesIndices) ->
  vertexIndices = [geom.faces[facesIndices[0]].a,
                   geom.faces[facesIndices[1]].a,
                   geom.faces[facesIndices[1]].b,
                   geom.faces[facesIndices[1]].c]

  [a,b,c,d] = (geom.vertices[i] for i in vertexIndices)
  newVectors = [
    midpoint(a,b),
    midpoint(a,c),
    midpoint(a,d),
    midpoint(b,c),
    midpoint(b,d),
    midpoint(c,d)]

  #faceIndices = [[0,4,5,6],
  #               [4,1,7,8],
  #               [7,2,5,9],
  #               [6,8,9,3]]

  o = vertexIndices
  n = geom.vertices.length #- newVectors.length
  [geom.vertices.push(new T.Vertex v) for v in newVectors]
  faceIndices = [[o[0], n+0,  n+1, n+2],
                 [ n+0, o[1], n+3, n+4],
                 [ n+3, o[2], n+1, n+5],
                 [ n+2, n+4,  n+5, o[3]]]

  faces = []
  for fi in faceIndices
    [a, b, c, d] = fi
    for face in triangleFaces([a,b,c,d])
       faces.push face
  geom.faces.splice(facesIndices[0],4)
  (geom.faces.push f for f in faces)

sierpinskyTetrahedron = (iterations)->
  geom = new THREE.Geometry()
  #Create initial triangle
  for i in [0..2]
    v = i*(2*Math.PI)/3
    x = Math.cos v
    y = Math.sin v
    z = (-1/Math.sqrt(3)/2)
    vector = new T.Vector3 x,y,z
    vertex = new T.Vertex vector
    geom.vertices.push vertex
  vector = new T.Vector3 0,0,Math.sqrt(3)/2
  geom.vertices.push new T.Vertex vector
  geom.faces = triangleFaces [0,1,2,3]

  n = (Math.pow(4,i) for i in [0..iterations]).reduce (t,s)->t+s
  for i in [0..n-1]
    subdivide geom, [0,1,2,3]
  return geom

init = ->
  renderer = new T.WebGLRenderer antialias: true
  renderer.setSize window.innerWidth, window.innerHeight
  scene = new T.Scene()
  camera = new T.PerspectiveCamera(
    60, # FOV
    window.innerWidth / window.innerHeight, # Ratio
    1, 10) #Near, Far

  camera.position.z = 3
  scene.add camera

  material = new T.MeshLambertMaterial
    color: 0xe0e0e0
    #color: 0xff0000
    #wireframe: true
    #wireframeLinewidth: 3.0
    vertexColors: T.FaceColors

  geo = sierpinskyTetrahedron(5)
  geo.computeFaceNormals()
  #geo.computeVertexNormals

  mesh = new T.Mesh geo, material
  scene.add mesh

  # create a point light
  pointLight = new T.PointLight 0xFFFFFF
  pointLight.position = new T.Vector3 5,5,15
  scene.add pointLight

  document.body.appendChild renderer.domElement

animate = ->
  requestAnimationFrame animate
  render()

render = ->
  mesh.rotation.x += 0.01
  mesh.rotation.y += 0.02
  mesh.rotation.z += 0.03
  renderer.render scene, camera

init()
animate()