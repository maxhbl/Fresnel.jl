macro pywraptype(type_name, module_name, supertype=Any)
    type_string = string(type_name)
    module_string = string(module_name)
    return quote
        global $type_name
        struct $type_name <: $supertype
            pyobj

            function $type_name(pyobj)
                name = pyconvert(String, pygetattr(pygetattr(pyobj, "__class__"), "__name__"))
                if name != $type_string 
                    error("Type names do not match. Cannot convert a $name to a $($type_string)")
                end
                return new(pyobj)
            end
        end
        function $type_name(args...; kwargs...)
            pyobj = try $module_name.$type_name(args...; kwargs...)
            catch
                error("Invalid arguments to python constructor.")
            end
            return $type_name(pyobj)
        end

        Base.show(io::Core.IO, x::$type_name) = println(io, getfield(x, :pyobj).__repr__())
        Base.getproperty(x::$type_name, f::Symbol) = pyconvert(Any, pygetattr(getfield(x, :pyobj), String(f)))
        ispy(x::$type_name) = true
        Py(x::$type_name) = getfield(x, :pyobj)
        Base.convert(::Type{$type_name}, x) = $type_name(x)
    end
end

macro pydefaultconvertrule(type_name, module_name)
    type_string = string(type_name)
    module_string = string(module_name)
    return :(PythonCall.pyconvert_add_rule($module_string * ":" * $type_string, $type_name, convert))
end

function slice_assign!(A::Py, val::AbstractMatrix)
    n, d = pyconvert(Tuple, A.shape)
    @assert size(val) == (n, d)
    for i in 1:n
        A[i-1] = val[i, :]
    end
end

function pyconvertfield(X, field_name::String, convert_type::Type=Any)
    return pyconvert(convert_type, pygetattr(getfield(X, :pyobj), field_name))
end
function pysetfield!(X, field_name::String, val::Any)
    return pysetattr(getfield(X, :pyobj), field_name, val)
end
function pyslicefield!(X, field_name::String, val::Any)
    f = pygetattr(getfield(X, :pyobj), field_name)
    slice_assign!(f, val)
    return
end