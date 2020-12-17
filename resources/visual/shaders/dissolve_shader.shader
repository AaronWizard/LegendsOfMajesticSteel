shader_type canvas_item;

uniform sampler2D dissolve_texture;
uniform float dissolve : hint_range(0, 1);

void fragment()
{
	vec4 current_pixel = texture(TEXTURE, UV);
	vec4 dissolve_pixel = texture(dissolve_texture, UV);

	if (dissolve_pixel.r > dissolve)
	{
		COLOR = current_pixel;
	}
	else
	{
		COLOR.a -= 1f;
	}
}