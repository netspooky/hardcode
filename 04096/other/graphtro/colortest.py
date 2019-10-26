import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation
from matplotlib.colors import LinearSegmentedColormap
import math, random

#Palette taken from the internet. May not be accurate
#0f380f Darkest Green   Hex: #0f380f RGB: 15, 56, 15
#306230 Dark Green      Hex: #306230 RGB: 48, 98, 48
#8bac0f Light Green     Hex: #8bac0f RGB: 139, 172, 15
#9bbc0f Lightest Green  Hex: #9bbc0f RGB: 155, 188, 15

cdict={'red':   ((0.0, 0.0, 0.15),
                 (0.25, 0.15, 0.48),
                 (0.50, 0.48, 0.139),
                 (0.75, 0.139, 0.155),
                 (1.00, 0.155, 1)),

       'green': ((0.0, 0.0, 0.56),
                 (0.25, 0.56, 0.98),
                 (0.50, 0.98, 0.172),
                 (0.75, 0.172, 0.188),
                 (1.00, 0.188, 1)),

       'blue':  ((0.0, 0.0, 0.15),
                 (0.25, 0.15, 0.48),
                 (0.50, 0.48, 0.15),
                 (0.75, 0.15, 0.15),
                 (1.00, 0.15, 1)),
      }

plt.register_cmap(name='gbmap', data=cdict)

gradient = np.linspace(0, 1, 256)
gradient = np.vstack((gradient, gradient))
fig, axes = plt.subplots()
fig.subplots_adjust(top=0.95, bottom=0.01, left=0.2, right=0.99)
axes.imshow(gradient, aspect='auto', cmap='gbmap')

plt.show()