import re
import math as m
import yaml
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

f = open("aggrigate_result.yml")
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

# メソッドの使用回数の順番でグラフにプロットを行う。

# 棒グラフで描画
def plot_graph():
    print("graph")
    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)
    ax.set_title('Discrete distribution map')
    ax.set_xlabel('rank')
    ax.set_ylabel('number of calls')

    ax.bar(list(range(1,len(data)+1)), data)
    fig.show()
    matplotlib.pyplot.savefig('distrubution_map.png')

plot_graph()

# 両対数グラフでプロットする
def plot_log_log_graph():
    print("graph2")
    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)
    ax.set_title('Discrete distribution map')
    ax.set_xlabel('log(rank)')
    ax.set_ylabel('log(number of calls)')

    # 両対数グラフでZipfの法則に従っているかを確認する
    left = np.array(list(map(lambda v: m.log(v), list(range(1,len(data)+1)))))
    right = np.array(list(map(lambda v: m.log(v), data)))
    ax.plot(left, right)
    fig.show()
    matplotlib.pyplot.savefig('log_distrubution_map.png')

plot_log_log_graph()
