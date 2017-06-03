import re
import math as m
import yaml
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

f = open("sort_result.yml")
data = yaml.load(f)
f.close()

data = data.items()
data = map(lambda i: i[1], data)
data = filter(lambda n: n>0 , data)
data = list(data)
data.sort()
data.reverse()

print(data)

matplotlib.pyplot.plot(data)

fig = plt.figure()
ax = fig.add_subplot(1,1,1)
ax.set_title('Discrete distribution map')
ax.set_xlabel('rank')
ax.set_ylabel('number of calls')

ax.bar(list(range(1,len(data)+1)), data)
fig.show()
matplotlib.pyplot.savefig('distrubution_map.png')

# メソッドの使用回数の順番でグラフにプロットを行う。
fig2 = plt.figure()
ax2 = fig2.add_subplot(1,1,1)
ax2.set_title('Discrete distribution map')
ax2.set_xlabel('log(rank)')
ax2.set_ylabel('log(number of calls)')

# 両対数グラフでZipfの法則に従っているかを確認する
left = np.array(list(map(lambda v: m.log(v), list(range(1,len(data)+1)))))
right = np.array(list(map(lambda v: m.log(v), data)))
ax2.plot(left, right)
fig2.show()
matplotlib.pyplot.savefig('log_distrubution_map.png')
