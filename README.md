# Fresnel.jl
Fresnel.jl is a simple wrapper around the [fresnel](https://github.com/glotzerlab/fresnel) raytracer (v0.13.5) written in Python/C++. The Julia interface here closely follows the Python version, the only difference being that object attributes are accessed using methods: Use `attribute(object)` to retrieve an attribute and `attribute!(object, value)` to modify it. Keeping this minor difference aside, the original [Python docs](https://fresnel.readthedocs.io/en/v0.13.5/index.html) should largely apply to this Julia wrapper as well.
## Example
This is a recreation of the original [introduction notebook](https://github.com/glotzerlab/fresnel-examples/blob/master/00-Basic-tutorials/00-Introduction.ipynb) in Julia.

Import `Fresnel` and create a scene with `Scene`:
```
using Fresnel
scene = Scene()
```
Add a geometry object to the scene
```
spheres = add_geometry!(scene, :sphere, N=8, radius=1.0)
# Alternatively:
# spheres = Sphere(scene, N=8, radius=1.0)
```
Note that to avoid collisions with `Base.position`, methods to access position attributes are named `pos` / `pos!`. Below we set the positions of the eight spheres using `pos!`:
```
pos!(spheres, [ 1  1  1;
		1  1 -1;
		1 -1  1;
		1 -1 -1;
               -1  1  1;
	       -1  1 -1;
               -1 -1  1;
               -1 -1 -1])
```
Other attributes are set similarly. Note the use of the `color_linear` function to convert color scales.
```
material!(spheres, Material(color=color_linear([0.25,0.5,0.9]), roughness=0.8))
```
Creating a camera fit to the scene is achieved with the function `fit_camera`, which takes the type of camera as the first argument (although only `Orthographic` is currently implemented):
```
camera!(scene, fit_camera(Orthographic, scene))
```
We can then render an image of our scene with `preview` or `pathtrace`:
```
image = preview(scene)
```
Rendering functions like `preview` and `pathtrace` return an `ImageArray`, which is displayed as an image in most Julia environments. The value of the array can be accessed via `image_array(image)`. If your environment does not automatically display an image, you can use the array data to manually create one.
