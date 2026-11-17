class_name Efectos
extends RefCounted

# EFECTOS VISUALES QUE SE CREAN Y SE BORRAN SOLOS

# GOTITAS QUE SALTAN DEL AGUA
static func salpicadura(padre: Node3D, pos: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.amount = 40
	p.lifetime = 0.9
	p.explosiveness = 0.9
	p.direction = Vector3.UP
	p.spread = 35.0
	p.initial_velocity_min = 2.5
	p.initial_velocity_max = 4.5
	p.gravity = Vector3(0, -9.8, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.3
	var gota := SphereMesh.new()
	gota.radius = 0.06
	gota.height = 0.12
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.75, 0.9, 1.0)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gota.material = mat
	p.mesh = gota
	padre.add_child(p)
	p.global_position = pos
	p.emitting = true
	p.finished.connect(p.queue_free)

# PEDACITOS DE HIELO QUE SALTAN Y SE HUNDEN EN EL AGUA
static func pedazos(padre: Node3D, pos: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.amount = 18
	p.lifetime = 1.3
	p.explosiveness = 1.0
	p.direction = Vector3.UP
	p.spread = 60.0
	p.initial_velocity_min = 1.5
	p.initial_velocity_max = 3.0
	p.gravity = Vector3(0, -9.8, 0)
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.2
	var trozo := BoxMesh.new()
	trozo.size = Vector3(0.12, 0.06, 0.12)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.7, 0.88, 1.0)
	mat.metallic = 0.2
	mat.roughness = 0.1
	trozo.material = mat
	p.mesh = trozo
	padre.add_child(p)
	p.global_position = pos
	p.emitting = true
	p.finished.connect(p.queue_free)
