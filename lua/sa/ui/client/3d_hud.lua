-- Create render target
local SA_HUD_RT = GetRenderTarget("SA_HUD_RT", ScrW(), ScrH())
local SA_HUD_RT_MAT = CreateMaterial("SA_HUD_RT_MAT", "UnlitGeneric", {
    ["$basetexture"] = SA_HUD_RT:GetName(),
    ["$model"] = 1,
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
})
local SA_HUD_WHITE_MAT = CreateMaterial("SA_HUD_WHITE_MAT", "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$model"] = 1,
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
})

local SA_HUD_MESH = Mesh(SA_HUD_RT_MAT)

-- configuration
local screen_fov = 75
local x_distance_factor = 0.75
local screen_spacing = 0
local screen_dist = 200
local tri_cols = 20
local tri_rows = 20

-- automatic calculations
local screen_fov_rad = math.rad(screen_fov)
local screen_fov_y_rad = 2*math.atan(math.tan(screen_fov_rad/2)/(ScrW()/ScrH()))

local screen_x_size = 2*math.tan(screen_fov_rad/2)*screen_dist
local screen_y_size = 2*math.tan(screen_fov_y_rad/2)*screen_dist

local tri_max_dist = math.tan((math.pi/2)-screen_fov_rad)*(screen_x_size/2)

local screen_y_size_max = 2*math.tan(screen_fov_y_rad/2)*(screen_dist+tri_max_dist)

screen_x_size = screen_x_size + screen_spacing*(screen_x_size/ScrW())
screen_y_size = screen_y_size + screen_spacing*(screen_y_size/ScrH())

local one_pixel_u_w = 1/ScrW()
local one_pixel_v_y = 1/ScrH()

local tri_width = screen_x_size / tri_cols
local tri_height = screen_y_size / tri_rows

local tri_rows_skip = 0
local tri_cols_skip = 0

tri_cols_skip = tri_cols_skip + 1
while tri_height * (tri_rows + tri_rows_skip*2) < screen_y_size_max do
	tri_rows_skip = tri_rows_skip + 1
end

local triangles = {}
local tri_rows_half = tri_rows / 2
local tri_rows_lim = tri_rows - 1
local tri_cols_half = tri_cols / 2
local tri_cols_lim = tri_cols - 1

local start_x = -tri_cols_skip
local end_x = tri_cols_lim + tri_cols_skip
local start_y = -tri_rows_skip
local end_y = tri_rows_lim + tri_rows_skip

local pi_half = math.pi/2
local D_offset = math.cos(-pi_half*x_distance_factor)*(tri_max_dist*x_distance_factor)

for y = start_y,end_y do
	local Y1 = (y - tri_rows_half) * tri_height
	local Y2 = Y1 + tri_height

	local yleft = tri_rows_lim - y
	local V2 = (yleft/tri_rows)
	local V1 = ((yleft+1)/tri_rows)

	V1 = math.Clamp(V1, one_pixel_v_y, 1-one_pixel_v_y)
	V2 = math.Clamp(V2, one_pixel_v_y, 1-one_pixel_v_y)

	for x = start_x,end_x do
		local X1 = (x - tri_cols_half) * tri_width
		local X2 = X1 + tri_width

		local D1 = math.cos((((x/tri_cols)*math.pi)-pi_half)*x_distance_factor)*(tri_max_dist*x_distance_factor)
		local D2 = math.cos(((((x+1)/tri_cols)*math.pi)-pi_half)*x_distance_factor)*(tri_max_dist*x_distance_factor)

		D1 = D1 - D_offset
		D2 = D2 - D_offset

		local xleft = tri_cols_lim - x
		local U2 = (xleft/tri_cols)
		local U1 = ((xleft+1)/tri_cols)
	
		U1 = math.Clamp(U1, one_pixel_u_w, 1-one_pixel_u_w)
		U2 = math.Clamp(U2, one_pixel_u_w, 1-one_pixel_u_w)

		-- D, X=U, Y=V
		-- clockwise ordering
		table.insert(triangles, { pos = Vector(D2, X2, Y1), u = U2, v = V1 })
		table.insert(triangles, { pos = Vector(D2, X2, Y2), u = U2, v = V2 })
		table.insert(triangles, { pos = Vector(D1, X1, Y1), u = U1, v = V1 })

		table.insert(triangles, { pos = Vector(D2, X2, Y2), u = U2, v = V2 })
		table.insert(triangles, { pos = Vector(D1, X1, Y2), u = U1, v = V2 })
		table.insert(triangles, { pos = Vector(D1, X1, Y1), u = U1, v = V1 })
	end
end
SA_HUD_MESH:BuildFromTriangles(triangles)

local use3DHUD = CreateClientConVar("cl_sa_use_3dhud", 0, true, false)

hook.Add("HUDPaint", "SA_HudPaintWrapper", function()
	if use3DHUD:GetInt() == 0 then
        hook.Call("SA_HUDPaint")
        return
    end

	render.PushRenderTarget(SA_HUD_RT, 0, 0, ScrW(), ScrH())
		cam.Start2D()
			render.OverrideAlphaWriteEnable(true, true)
			render.ClearDepth()
			render.Clear(0, 0, 0, 0)
			hook.Call("SA_HUDPaint")
			render.OverrideAlphaWriteEnable(false)
		cam.End2D()
	render.PopRenderTarget()

	cam.Start3D(Vector(-screen_dist,0,0), Angle(0,0,0), screen_fov)
		render.SetMaterial(SA_HUD_RT_MAT)
		SA_HUD_MESH:Draw()
	cam.End3D()
end)
