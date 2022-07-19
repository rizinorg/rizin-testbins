#!/usr/bin/env python3

from print_stats import calc_stats
from os import listdir
import sys

def print_most_common(path: str, perc: float):
	most_common = dict()
	sum_all = 0
	for file in listdir(path):
		if file[-6:] != '.stats':
			continue
		with open(file) as f:
			lines = f.readlines()
		esil, rzil, both, none, sum_insn = calc_stats(lines)
		sum_all += sum_insn
		for i in none:
			name = i['name']
			if name in most_common:
				most_common[name] += i['count']
			else:
				most_common[name] = i['count']
	most_common = {k: v for k, v in sorted(most_common.items(), reverse=True, key=lambda item: item[1])}
	for i, c in most_common.items():
		p = c/sum_all
		if p > perc:
			print(f'{i}: {p:.5%}')
	print(f'Total: {sum_all}')


def print_help():
	print(f'{sys.argv[0]} <path to .stats files> <percent>')

if __name__ == '__main__':
	if len(sys.argv) != 3 or sys.argv[1] == '-h' or sys.argv[1] == '--help':
		print_help()
		exit()

	path = sys.argv[1]
	perc = float(sys.argv[2])
	print_most_common(path, perc)
	
