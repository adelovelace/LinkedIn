import random
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px

import dash
from dash.dependencies import Input, Output
from dash import html

from dash import Dash, html, dcc

import dash_cytoscape as cyto

#load data
df = pd.read_csv('/Users/andrea/Documents/Espol/2T-2022/Lenguajes de Programación/2Parcial/Proyecto/LinkedIn/data/works_v1.csv')

df['city']= df['location'].apply(lambda x: x.split(",")[0])
df['state']= df['location'].apply(lambda x: x.split(",")[1])



app = Dash(__name__)

# assume you have a "long-form" data frame
# see https://plotly.com/python/px-arguments/ for more options

fig = px.histogram(df, x="city")
fig_state = px.histogram(df, x="state")

app.layout = html.Div(children=[
    html.Div(children=[
        html.H1(children='Works by City'),
        html.Div(children=''''''),
        dcc.Graph(
            id='example-graph',
            figure=fig
        )
    ]),
    html.Div(children=[
        html.H1(children='Works by State'),
        html.Div(children=''''''),
        dcc.Graph(
            id='example-graph',
            figure=fig_state
        )
    ])
    
])

if __name__ == '__main__':
    app.run_server(debug=True)