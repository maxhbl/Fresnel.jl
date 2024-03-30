module Fresnel

using PythonCall

const fresnel = PythonCall.pynew()
include("utils.jl")

function __init__()
    PythonCall.pycopy!(fresnel, pyimport("fresnel"))
end

export Scene, 
    camera!, backgroundalpha!, backgroundcolor!, lights!,

    Device,

    Tracer, Preview, Path,
    seed!, antialias!,

    Orthographic, Perspective,
    position!, lookat!, updir!, height!,
    focallength!, fstop!, focusdistance!,
    depthoffield!, focuson!, verticalFOV!,

    Material, 
    solid!, primitivecolormix!, color!, roughness!,
    specular!, spectrans!, metal!,    

    Light,
    direction!, color!, theta!,

    Cylinder, Box, Polygon, Sphere, Mesh, ConvexPolyhedron,
    material!, outlinematerial!, outlinewidth!, box!, boxcolor!,
    boxradius!, colorbyface!,

    linear_color, orthographic_fit, preview, pathtrace

abstract type AbstractCamera end
abstract type AbstractLight end
abstract type AbstractMaterial end
abstract type AbstractGeometry end
abstract type AbstractTracer end

@pywraptype Orthographic fresnel.camera AbstractCamera
@pywraptype Perspective fresnel.camera AbstractCamera
position!(c::AbstractCamera, pos::AbstractVector) = pysetattr(getfield(c, :pyobj), "position", pos)
lookat!(c::AbstractCamera, lookat::AbstractVector) = pysetattr(getfield(c, :pyobj), "look_at", lookat)
updir!(c::AbstractCamera, up::AbstractVector) = pysetattr(getfield(c, :pyobj), "up", up)
height!(c::AbstractCamera, height::Real) = pysetattr(getfield(c, :pyobj), "height", height)
focallength!(c::Perspective, f::Real) = pysetattr(getfield(c, :pyobj), "focal_length", f)
fstop!(c::Perspective, f::Real) = pysetattr(getfield(c, :pyobj), "f_stop", f)
focusdistance!(c::Perspective, dist::Real) = pysetattr(getfield(c, :pyobj), "focus_distance", dist)
depthoffield!(c::Perspective, dof::Real) = pysetattr(getfield(c, :pyobj), "depth_of_field", dof)
focuson!(c::Perspective, focuson::AbstractVector) = pysetattr(getfield(c, :pyobj), "focus_on", focuson)
verticalFOV!(c::Perspective, fov::Real) = pysetattr(getfield(c, :pyobj), "vertical_field_of_view", fov)

@pywraptype Light fresnel.light AbstractLight
@pywraptype _LightProxy fresnel.light AbstractLight
@pywraptype _LightListProxy fresnel.light AbstractLight
direction!(l::AbstractLight, dir::AbstractVector) = pysetattr(getfield(l, :pyobj), "direction", dir)
color!(l::AbstractLight, color::AbstractVector) = pysetattr(getfield(l, :pyobj), "color", color)
theta!(l::AbstractLight, θ::Real) = pysetattr(getfield(l, :pyobj), "theta", θ)

@pywraptype Material fresnel.material AbstractMaterial
@pywraptype _MaterialProxy fresnel.material AbstractMaterial
@pywraptype _OutlineMaterialProxy fresnel.material AbstractMaterial
solid!(m::AbstractMaterial, v::Real) = pysetattr(getfield(m, :pyobj), "solid", v)
primitivecolormix!(m::AbstractMaterial, v::Real) = pysetattr(getfield(m, :pyobj), "primitive_color_mix", v)
color!(m::AbstractMaterial, color::AbstractVector) = pysetattr(getfield(m, :pyobj), "color", color)
roughness!(m::AbstractMaterial, v::Real) = pysetattr(getfield(m, :pyobj), "roughness", v)
specular!(m::AbstractMaterial, v::Real) = pysetattr(getfield(m, :pyobj), "specular", v)
spectrans!(m::AbstractMaterial, v::Real) = pysetattr(getfield(m, :pyobj), "spec_trans", v)
metal!(m::AbstractMaterial, v::Real) = pysetattr(getfield(m, :pyobj), "metal", v)

@pywraptype Cylinder fresnel.geometry AbstractGeometry
@pywraptype Box fresnel.geometry AbstractGeometry
@pywraptype Polygon fresnel.geometry AbstractGeometry
@pywraptype Sphere fresnel.geometry AbstractGeometry
@pywraptype Mesh fresnel.geometry AbstractGeometry
@pywraptype ConvexPolyhedron fresnel.geometry AbstractGeometry
function position!(g::AbstractGeometry, pos::AbstractArray)
    p = getfield(g, :pyobj).position
    n, d = pyconvert(Tuple, p.shape)
    @assert size(pos) == (n, d)
    for i in 1:n
        p[i-1] = pos[i, :]
    end
    return
end
material!(g::AbstractGeometry, material::Material) = pysetattr(getfield(g, :pyobj), "material", material)
outlinematerial!(g::AbstractGeometry, material::Material) = pysetattr(getfield(g, :pyobj), "outline_material", material)
outlinewidth!(g::AbstractGeometry, width::Real) = pysetattr(getfield(g, :pyobj), "outline_width", width)
box!(g::Box, box::AbstractVector) = pysetattr(getfield(g, :pyobj), "box", box)
boxcolor!(g::Box, color::AbstractVector) = pysetattr(getfield(g, :pyobj), "box_color", color)
boxradius!(g::Box, r::Real) = pysetattr(getfield(g, :pyobj), "box_radius", r)
colorbyface!(g::ConvexPolyhedron, color::AbstractVector) = pysetattr(getfield(g, :pyobj), "color_by_face", color)

@pywraptype Preview fresnel.tracer AbstractTracer
@pywraptype Path fresnel.tracer AbstractTracer
seed!(t::AbstractTracer, v::Number) = pysetattr(getfield(t, :pyobj), "seed", v)
antialias!(t::Preview, v::Bool) = pysetattr(getfield(t, :pyobj), "anti_alias", v)

@pywraptype Scene fresnel
camera!(s::Scene, camera::AbstractCamera) = pysetattr(getfield(s, :pyobj), "camera", getfield(camera, :pyobj))
backgroundcolor!(s::Scene, color::AbstractVector) = pysetattr(getfield(s, :pyobj), "background_color", color)
backgroundalpha!(s::Scene, alpha::Real) = pysetattr(getfield(s, :pyobj), "background_alpha", alpha)
lights!(s::Scene, light::Light) = pysetattr(getfield(s, :pyobj), "lights", light)

@pywraptype Device fresnel

@pywraptype ImageArray fresnel.util
Base.display(iarr::ImageArray) = display(getfield(iarr, :pyobj))

PythonCall.pyconvert_add_rule("fresnel.util:Array", Array, (T, x)->pyconvert(T, x.buf))

function linear_color(color)
    return pyconvert(Vector, fresnel.color.linear(color))
end
function orthographic_fit(scene::Scene)
    return Orthographic(fresnel.camera.Orthographic.fit(scene))
end
function preview(scene::Scene; kwargs...)
    return pyconvert(ImageArray, fresnel.preview(scene; kwargs...))
end
function pathtrace(scene::Scene; kwargs...)
   return pyconvert(ImageArray, fresnel.pathtrace(scene; kwargs...))
end

end
