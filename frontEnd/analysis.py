import random
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import re

from os import path
from PIL import Image
from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator

import nltk

#for NLP purpose
from nltk.corpus import stopwords
nltk.download('stopwords')

import plotly
import plotly.graph_objs as go

import dash
from dash.dependencies import Input, Output
from dash import html

from dash import Dash, html, dcc

import dash_cytoscape as cyto

#load data
df = pd.read_excel('/Users/andrea/Documents/Espol/2T-2022/Lenguajes de Programación/2Parcial/Proyecto/LinkedIn/data/works_v3.xlsx')

# reset the header 
new_header_df = df.iloc[0]
df.columns = new_header_df

#reset index
df = df.iloc[1:,]
df = df.reset_index(drop=True)

df['City']= df['Location'].apply(lambda x: x.split(",")[0])

#Move last Column to the desire position
new_cols = ['Job Title', 'Company Info', 'Company Name', 'Location','City' ,'Working mode','Time post', 'Current Applicants', 'Job Description']
df=df[new_cols]

#analysis per state

new_cols_state = ['Job Title', 'Company Info', 'Company Name', 'Location', 'City','State',
       'Working mode', 'Time post', 'Current Applicants', 'Job Description']

# dataset de berlin
df_berlin = df.iloc[:23,]
# df_berlin['State'] = "Berlin"
df_berlin.loc[:,'State'] = str('Berlin')
df_berlin=df_berlin[new_cols_state]


# dataset de hessen
df_hessen = df.iloc[23:47,]
# df_hessen['State'] = "Hessen"
df_hessen.loc[:,'State'] = str('Hessen')
df_hessen = df_hessen[new_cols_state]

regex = 'Frankf.*'
df_hessen.City = df_hessen.City.replace(regex=[regex],value='Frankfurt')

# dataset de bayern
df_bayern = df.iloc[47:,]
# df_bayern['State'] = "Bayern"
df_bayern.loc[:,'State'] = str('Bayern')
df_bayern = df_bayern[new_cols_state]



app = Dash(__name__)

# fig = px.histogram(df, x="city")
fig_state_berlin = px.histogram(df_berlin, x="City")
fig_state_hessen = px.histogram(df_hessen, x="City")
fig_state_bayern = px.histogram(df_bayern, x="City")

def cleanText(dataF):
    stop = stopwords.words('english') + stopwords.words('german')
    dataF['Job Description'] = dataF['Job Description'].apply(lambda x: str(x))
    #convert to lower 
    dataF['Job Description'] = dataF['Job Description'].apply(lambda x: ' '.join([word for word in x.lower().split() if word not in (stop)]))
    #Remove Punctuations
    dataF['Job Description'] = dataF['Job Description'].str.replace('[^\w\s]','')

cleanText(df_berlin)
cleanText(df_hessen)
cleanText(df_bayern)

#Count Words
countFreq_berlin = df_berlin['Job Description'].str.split(expand=True).stack().value_counts()[:100]
countFreq_hessen = df_hessen['Job Description'].str.split(expand=True).stack().value_counts()[:100]
countFreq_bayern = df_bayern['Job Description'].str.split(expand=True).stack().value_counts()[:100]

app.layout = html.Div(children=[
    html.Div(children=[
        html.H1(children='Works by State'),
        html.Div(children=''''''),
        dcc.Graph(
            id='berlin',
            figure=fig_state_berlin
        ),
        dcc.Graph(
            id='hessen',
            figure=fig_state_hessen
        ),
        dcc.Graph(
            id='bayern',
            figure=fig_state_bayern
        ),
    
    ]),
    html.Div(children=[
        dcc.Graph(
                id='frequency_word_bargraph_berlin',
                figure={
                    'data': [
                        {
                            'x': countFreq_berlin.index,
                            'y': countFreq_berlin.values,
                            'name': 'Berlin',
                            'type': 'bar'
                        }
                    ],
                    'layout': {
                        'title': 'Berlin Word Frequency.'
                    }
                },
                style={
                        'display': 'block'
                },
                className='twelve columns'
            ),
                    dcc.Graph(
                id='frequency_word_bargraph_hessen',
                figure={
                    'data': [
                        {
                            'x': countFreq_hessen.index,
                            'y': countFreq_hessen.values,
                            'name': 'Hessen',
                            'type': 'bar'
                        }
                    ],
                    'layout': {
                        'title': 'Hessen Word Frequency.'
                    }
                },
                style={
                        'display': 'block'
                },
                className='twelve columns'
            ),
                    dcc.Graph(
                id='frequency_word_bargraph_bayern',
                figure={
                    'data': [
                        {
                            'x': countFreq_bayern.index,
                            'y': countFreq_bayern.values,
                            'name': 'Bayern',
                            'type': 'bar'
                        }
                    ],
                    'layout': {
                        'title': 'Bayern Word Frequency.'
                    }
                },
                style={
                        'display': 'block'
                },
                className='twelve columns'
            )
            
            ],
            className='row')
    # html.Div(children=[
    #     html.H1(children='Works by State'),
    #     html.Div(children=''''''),
    #     dcc.Graph(
    #         id='example-graph',
    #         figure=fig_state
    #     )
    # ])
    
])

if __name__ == '__main__':
    app.run_server(debug=True)