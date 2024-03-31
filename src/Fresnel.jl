module Fresnel

using PythonCall
include("utils.jl")

export Scene, 
    camera, camera!, background_alpha, background_alpha!,
    background_color, background_color!, lights, lights!,
    extents,

    Device,
    mode,

    Tracer, Preview, Path,
    seed, seed!, anti_alias, anti_alias!,

    Orthographic, Perspective,
    basis, pos, pos!, look_at, look_at!, up_dir, up_dir!,
    height, height!, focal_length, focal_length!, f_stop, 
    f_stop!, focus_distance, focus_distance!, depth_of_field,
    depth_of_field!, focus_on, focus_on!, vertical_FOV, vertical_FOV!,

    Material, 
    solid, solid!, primitive_colormix, primitive_colormix!, color, color!,
    roughness, roughness!, specular, specular!, spec_trans, spec_trans!,
    metal, metal!,    

    Light,
    direction, direction!, color, color!, theta, theta!,

    Cylinder, Box, Polygon, Sphere, Mesh, ConvexPolyhedron,
    material, material!, outline_material,outline_material!,
    outline_width, outline_width!, box, box!, radius, radius!,
    color, color!, color_by_face, color_by_face!, angle, angle!,
    orientation, orientation!, enable!, disable!, remove!, extents,

    color_linear, fit_camera, preview, pathtrace, image_array, pyglobals


const fresnel = PythonCall.pynew()

function __init__()
    PythonCall.pycopy!(fresnel, pyimport("fresnel"))

    @pydefaultconvertrule Orthographic fresnel.camera 
    @pydefaultconvertrule Perspective fresnel.camera 
    @pydefaultconvertrule Light fresnel.light 
    @pydefaultconvertrule _LightProxy fresnel.light 
    @pydefaultconvertrule _LightListProxy fresnel.light
    @pydefaultconvertrule Material fresnel.material
    @pydefaultconvertrule _MaterialProxy fresnel.material
    @pydefaultconvertrule _OutlineMaterialProxy fresnel.material
    @pydefaultconvertrule Cylinder fresnel.geometry
    @pydefaultconvertrule Box fresnel.geometry
    @pydefaultconvertrule Polygon fresnel.geometry
    @pydefaultconvertrule Sphere fresnel.geometry
    @pydefaultconvertrule Mesh fresnel.geometry
    @pydefaultconvertrule ConvexPolyhedron fresnel.geometry
    @pydefaultconvertrule Preview fresnel.tracer
    @pydefaultconvertrule Path fresnel.tracer
    @pydefaultconvertrule Scene fresnel
    @pydefaultconvertrule Device fresnel

    PythonCall.pyconvert_add_rule("fresnel.util:Array", Array, (T, x)->pyconvert(T, x.buf))
    PythonCall.pyconvert_add_rule("fresnel.util:ImageArray", ImageArray, (T, x)->convert(T, x))
end

abstract type AbstractCamera end
abstract type AbstractLight end
abstract type AbstractMaterial end
abstract type AbstractGeometry end
abstract type AbstractTracer end

@pywraptype Orthographic fresnel.camera AbstractCamera
@pywraptype Perspective fresnel.camera AbstractCamera
basis(c::AbstractCamera) = pyconvertfield(c, "basis", Array)
pos(c::AbstractCamera) = pyconvertfield(c, "position", Vector)
pos!(c::AbstractCamera, val::AbstractVector) = pysetfield!(c, "position", val)
look_at(c::AbstractCamera) = pyconvertfield(c, "look_at", Vector)
look_at!(c::AbstractCamera, val::AbstractVector) = pysetfield!(c, "look_at", val)
up_dir(c::AbstractCamera) = pyconvertfield(c, "up", Vector)
up_dir!(c::AbstractCamera, val::AbstractVector) = pysetfield!(c, "up", val)
height(c::AbstractCamera) = pyconvertfield(c, "height", Real)
height!(c::AbstractCamera, val::Real) = pysetfield!(c, "height", val)
focal_length(c::Perspective) = pyconvertfield(c, "focal_length", Real)
focal_length!(c::Perspective, val::Real) = pysetfield!(c, "focal_length", val)
f_stop(c::Perspective) = pyconvertfield(c, "f_stop", Real)
f_stop!(c::Perspective, val::Real) = pysetfield!(c, "f_stop", val)
focus_distance(c::Perspective) = pyconvertfield(c, "focus_distance", Real)
focus_distance!(c::Perspective, val::Real) = pysetfield!(c, "focus_distance", val)
depth_of_field(c::Perspective) = pyconvertfield(c, "depth_of_field", Real)
depth_of_field!(c::Perspective, val::Real) = pysetfield!(c, "depth_of_field", val)
focus_on(c::Perspective) = pyconvertfield(c, "focus_on", Vector)
focus_on!(c::Perspective, val::AbstractVector) = pysetfield!(c, "focus_on", val)
vertical_FOV(c::Perspective) = pyconvertfield(c, "vertical_field_of_view", Real)
vertical_FOV!(c::Perspective, val::Real) = pysetfield!(c, "vertical_field_of_view", val)

@pywraptype Light fresnel.light AbstractLight
@pywraptype _LightProxy fresnel.light AbstractLight
@pywraptype _LightListProxy fresnel.light
direction(l::AbstractLight) = pyconvertfield(l, "direction", Vector)
direction!(l::AbstractLight, val::AbstractVector) = pysetfield!(l, "direction", val)
color(l::AbstractLight) = pyconvertfield(l, "color", Vector)
color!(l::AbstractLight, val::AbstractVector) = pysetfield!(l, "color", val)
theta(l::AbstractLight) = pyconvertfield(l, "color", Real)
theta!(l::AbstractLight, val::Real) = pysetfield!(l, "theta", val)

@pywraptype Material fresnel.material AbstractMaterial
@pywraptype _MaterialProxy fresnel.material AbstractMaterial
@pywraptype _OutlineMaterialProxy fresnel.material AbstractMaterial
solid(m::AbstractMaterial) = pyconvertfield(m, "solid", Real)
solid!(m::AbstractMaterial, val::Real) = pysetfield!(m, "solid", val)
primitive_colormix(m::AbstractMaterial) = pyconvertfield(m, "primitive_color_mix!", Real)
primitive_colormix!(m::AbstractMaterial, val::Real) = pysetfield!(m, "primitive_color_mix", val)
color(m::AbstractMaterial) = pyconvertfield(m, "color", Vector)
color!(m::AbstractMaterial, val::AbstractVector) = pysetfield!(m, "color", val)
roughness(m::AbstractMaterial) = pyconvertfield(m, "roughness", Real)
roughness!(m::AbstractMaterial, val::Real) = pysetfield!(m, "roughness", val)
specular(m::AbstractMaterial) = pyconvertfield(m, "specular", Real)
specular!(m::AbstractMaterial, val::Real) = pysetfield!(m, "specular", val)
spec_trans(m::AbstractMaterial) = pyconvertfield(m, "spec_trans", Real)
spec_trans!(m::AbstractMaterial, val::Real) = pysetfield!(m, "spec_trans", val)
metal(m::AbstractMaterial) = pyconvertfield(m, "metal", Real)
metal!(m::AbstractMaterial, val::Real) = pysetfield!(m, "metal", val)

@pywraptype Cylinder fresnel.geometry AbstractGeometry
@pywraptype Box fresnel.geometry AbstractGeometry
@pywraptype Polygon fresnel.geometry AbstractGeometry
@pywraptype Sphere fresnel.geometry AbstractGeometry
@pywraptype Mesh fresnel.geometry AbstractGeometry
@pywraptype ConvexPolyhedron fresnel.geometry AbstractGeometry
enable!(g::AbstractGeometry) = pyconvert(Any, g.enable())
disable!(g::AbstractGeometry) = pyconvert(Any, g.disable())
remove!(g::AbstractGeometry) = pyconvert(Any, g.remove())
extents(g::AbstractGeometry) = pyconvert(Array, g.get_extents())

pos(g::AbstractGeometry) = pyconvertfield(g, "position", Array)
pos(g::Cylinder) = points(g)
pos!(g::AbstractGeometry, val::AbstractArray) = pyslicefield!(g, "position", val)
pos!(g::Cylinder, val::AbstractArray) = points!(g, val)

points(g::Cylinder) = pyconvertfield(g, "points", Array)
points!(g::Cylinder, val::AbstractArray) = pyslicefield!(g, "points", val)

radius(g::Cylinder) = pyconvertfield(g, "radius", Vector)
radius!(g::Cylinder, val::AbstractVector) = pyslicefield!(g, "radius", val)
radius(g::Sphere) = pyconvertfield(g, "radius", Vector)
radius!(g::Sphere, val::AbstractVector) = pyslicefield!(g, "radius", val)
radius(g::Box) = pysetfield!(g, "box_radius", Real)
radius!(g::Box, val::Real) = pysetfield!(g, "box_radius", val)

color(g::AbstractGeometry) = pyconvertfield(g, "color", Array)
color!(g::AbstractGeometry, val::AbstractArray) = pyslicefield!(g, "color", val)
color(g::Box) = pyconvertfield(g, "box_color", Vector)
color!(g::Box, val::AbstractVector) = pysetfield!(g, "box_color", val)

angle(g::Polygon) = pyconvertfield(g, "angle", Vector)
angle!(g::Polygon, val::AbstractVector) = pyslicefield!(g, "angle", val)
orientation(g::Mesh) = pyconvertfield(g, "orientation", Array)
orientation!(g::Mesh, val::AbstractArray) = pyslicefield!(g, "orientation", val)
orientation(g::ConvexPolyhedron) = pyconvertfield(g, "orientation", Array)
orientation!(g::ConvexPolyhedron, val::AbstractArray) = pyslicefield!(g, "orientation", val)

material(g::AbstractGeometry) = pyconvertfield(g, "material", Material)
material!(g::AbstractGeometry, val::Material) = pysetfield!(g, "material", val)
outline_material(g::AbstractGeometry) = pyconvertfield(g, "outline_material", Material)
outline_material!(g::AbstractGeometry, val::Material) = pysetfield!(g, "outline_material", val)
outline_width(g::AbstractGeometry) = pyconvertfield(g, "outline_width", Real)
outline_width!(g::AbstractGeometry, val::Real) = pysetfield!(g, "outline_width", val)
box(g::Box) = pyconvertfield(g, "box", Vector)
box!(g::Box, val::AbstractVector) = pysetfield!(g, "box", val)
color_by_face(g::ConvexPolyhedron) = pyconvertfield(g, "color_by_face", Vector)
color_by_face!(g::ConvexPolyhedron, val::AbstractVector) = pysetfield!(g, "color_by_face", val)

@pywraptype Preview fresnel.tracer AbstractTracer
@pywraptype Path fresnel.tracer AbstractTracer
seed(t::AbstractTracer) = pyconvertfield(t, "seed", Number)
seed!(t::AbstractTracer, val::Number) = pysetfield!(t, "seed", val)
anti_alias(t::AbstractTracer) = pyconvertfield(t, "anti_alias", Bool)
anti_alias!(t::Preview, val::Bool) = pysetfield!(t, "anti_alias", val)

@pywraptype Scene fresnel
extents(s::Scene) = pyconvert(Array, s.get_extents())
camera(s::Scene) = pyconvertfield(s, "camera", AbstractCamera)
camera!(s::Scene, val::AbstractCamera) = pysetfield!(s, "camera", getfield(val, :pyobj))
background_color(s::Scene) = pyconvertfield(s, "background_color", Vector)
background_color!(s::Scene, val::AbstractVector) = pysetfield!(s, "background_color", val)
background_alpha(s::Scene) = pyconvertfield(s, "background_alpha", Real)
background_alpha!(s::Scene, val::Real) = pysetfield!(s, "background_alpha", val)
lights(s::Scene) = pyconvertfield(s, "lights", _LightListProxy)
lights!(s::Scene, val::AbstractVector{<:AbstractLight}) = pysetfield!(s, "lights", getfield(val, :pyobj))

@pywraptype Device fresnel
mode(d::Device) = pyconvert(String, d.mode)

@pywraptype ImageArray fresnel.util
Base.display(iarr::ImageArray) = display(getfield(iarr, :pyobj))
image_data(iarr::ImageArray) = pyconvert(Array, iarr.buf)

function color_linear(color)
    return pyconvert(Vector, fresnel.color.linear(color))
end
function fit_camera(::Type{Orthographic}, scene::Scene)
    return Orthographic(fresnel.camera.Orthographic.fit(scene))
end
function preview(scene::Scene; kwargs...)
    return pyconvert(ImageArray, fresnel.preview(scene; kwargs...))
end
function pathtrace(scene::Scene; kwargs...)
   return pyconvert(ImageArray, fresnel.pathtrace(scene; kwargs...))
end

end
