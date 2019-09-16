/*
 * Copyright © 2019 Keith Packard <keithp@keithp.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 */

#include "snek.h"
#include <math.h>

snek_poly_t
snek_builtin_input(uint8_t nposition, uint8_t nnamed, snek_poly_t *args)
{
	char		in[2] = {0, 0};
	int		c;
	snek_poly_t	s = SNEK_NULL;

	while (nposition--) {
		snek_poly_t arg = *args++;
		snek_poly_print(stdout, arg, 's');
		if (nposition)
			putc(' ', stdout);
	}
	(void) nnamed;
	fflush(stdout);
	while ((c = getchar()) != '\n' && c != EOF) {
		if (snek_is_null(s)) {
			s = snek_string_make(c);
		} else {
			in[0] = c;
			s = snek_string_cat(snek_poly_to_string(s), in);
		}
	}
	return s;
}

snek_poly_t
snek_builtin_float(snek_poly_t a)
{
	if (snek_poly_type(a) != snek_string)
		return snek_error_type_1(a);
	return snek_float_to_poly(strtof(snek_poly_to_string(a), NULL));
}

snek_poly_t
snek_builtin_int(snek_poly_t a)
{
	if (snek_poly_type(a) != snek_string)
		return snek_error_type_1(a);
	return snek_float_to_poly(truncf(strtof(snek_poly_to_string(a), NULL)));
}