// SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
// SPDX-License-Identifier: LGPL-3.0-only

__attribute__((noinline)) double scale(int n, double x) {
	double s = 0;
	for (int i = 0; i < n; i++) {
		s = s * x + i;
	}
	return s;
}

int main(int argc, char **argv) {
	return (int)scale(argc, 2.0);
}
