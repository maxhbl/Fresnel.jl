### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 0b1a0b64-e87c-4c78-b253-6a4f49a37fd9
using Fresnel

# ╔═╡ 3a73e9fb-2087-4d62-8ea6-aba443dd9344
md"# Introduction to Fresnel.jl
Fresnel.jl is a simple wrapper around the [fresnel](https://github.com/glotzerlab/fresnel) raytracer written in Python/C++. The Julia interface here closely follows the Python version. The 'pythonic' way of accessing object attributes (e.g. `object.attribute`) is replaced with the idiomatic Julia way, which is to use methods: Use `attribute(object)` to retrieve an attribute and `attribute!(object, value)` to modify it. Keeping this minor difference aside, the original [Python docs](https://fresnel.readthedocs.io/en/v0.13.5/index.html) should largely apply to this Julia wrapper as well. This notebook is a Julia version of the introductory notebook found [here](https://github.com/glotzerlab/fresnel-examples)) and highlights some different access patterns of this wrapper.
"

# ╔═╡ 079d934d-8ca5-4375-9526-53c4498f2973
scene = Scene()

# ╔═╡ 9a187199-863c-4d80-9c4a-bfe379f6e991
geometry = Sphere(scene, N=8, radius=1.0)

# ╔═╡ ab03c323-750b-4e04-b6ef-7e7d062aa304
md"Note that to avoid collisions with `Base.position`, methods to access position attributes are named `pos` / `pos!`. Below we set the positions of the eight spheres using `pos!`:"

# ╔═╡ 992fce87-4ee4-4500-b67d-e8ef10aae971
pos!(geometry, [ 1  1  1;
	  			 1  1 -1;
	 			 1 -1  1;
				 1 -1 -1;
	 			-1  1  1;
	 			-1  1 -1;
	 			-1 -1  1;
	 			-1 -1 -1])

# ╔═╡ 67328f50-5afb-4c8f-967d-b0400cdcab88
md"We can inspect the positions of a geometry with `pos`:"

# ╔═╡ 1c169153-5bc1-4a43-a416-1fb67c112ee5
pos(geometry)

# ╔═╡ 63fdc0c5-fbcc-47a5-89ca-d9ff4666048f
md"Other attributes are set similarly. Note the use of the `color_linear` function to convert color scales."

# ╔═╡ 352ff661-4953-4bca-8ad9-3b89f51c34e4
material!(geometry, Material(color=color_linear([0.25,0.5,0.9]), roughness=0.8))

# ╔═╡ b8cc03c1-fd01-4ebf-96ac-2329461cd41a
md"Creating a camera fit to the scene is achieved with the function fit_camera, which takes the type of camera as the first argument (although only Orthographic is currently implemented):"

# ╔═╡ a5ba90a6-d732-4de2-bd05-8ca45774d573
camera!(scene, fit_camera(Orthographic, scene))

# ╔═╡ 8469cc95-f0e3-4374-9419-c7c7130c1deb
md"We can then render an image of our scene with `preview` or `pathtrace`:"

# ╔═╡ 3818e2a7-5492-4dfc-8dff-9424d8aa1262
image = preview(scene)

# ╔═╡ 56e5a7e8-be4b-497d-ada3-49b7feeb796a
md"Rendering functions like `preview` and `pathtrace` return an `ImageArray`, which should be displayed as an image. The value of the array can be accessed via `image_array(image)`, as below. If your environment does not automatically display an image, you can use the array data to manually create one."

# ╔═╡ 4b1e518f-1af8-4f07-8a7e-87df4c0d1050
arr = image_data(image)

# ╔═╡ Cell order:
# ╟─3a73e9fb-2087-4d62-8ea6-aba443dd9344
# ╠═0b1a0b64-e87c-4c78-b253-6a4f49a37fd9
# ╠═079d934d-8ca5-4375-9526-53c4498f2973
# ╠═9a187199-863c-4d80-9c4a-bfe379f6e991
# ╟─ab03c323-750b-4e04-b6ef-7e7d062aa304
# ╠═992fce87-4ee4-4500-b67d-e8ef10aae971
# ╟─67328f50-5afb-4c8f-967d-b0400cdcab88
# ╠═1c169153-5bc1-4a43-a416-1fb67c112ee5
# ╟─63fdc0c5-fbcc-47a5-89ca-d9ff4666048f
# ╠═352ff661-4953-4bca-8ad9-3b89f51c34e4
# ╟─b8cc03c1-fd01-4ebf-96ac-2329461cd41a
# ╠═a5ba90a6-d732-4de2-bd05-8ca45774d573
# ╟─8469cc95-f0e3-4374-9419-c7c7130c1deb
# ╠═3818e2a7-5492-4dfc-8dff-9424d8aa1262
# ╟─56e5a7e8-be4b-497d-ada3-49b7feeb796a
# ╠═4b1e518f-1af8-4f07-8a7e-87df4c0d1050
