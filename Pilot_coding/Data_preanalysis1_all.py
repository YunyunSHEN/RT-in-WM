# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from sklearn.metrics import mean_squared_error
import scipy.stats
import pingouin as pg

import os
import glob
# import pickle
 
#%% import data
path = os.getcwd()
csv_files = glob.glob(os.path.join(path, "*block_1*"))
Data_1 = {}
number_sub = len(csv_files)
for i in range(number_sub):
    print(csv_files[i])
    Data_1[i] = pd.read_csv(csv_files[i])
number_sub = len(csv_files)

#%% check wrong clicks  delate the trials with wrong number of clicks
#check wrong_clicks
data={}
for i in range(number_sub):
    if len(Data_1[i])!= 80:
        print(i)
        data[i] = Data_1[i]
        row_index= data[i][data[i]['got_clicks'] != 2].index.tolist()
        print(row_index)
        if len(row_index)>9:
            print('bad participant')
        Data_1[i]= data[i].drop(row_index).reset_index()

#%% check the correlation between participants' reproduction and the sequence
from scipy.stats import pearsonr
for i in range(number_sub):
    x = Data_1[i]['sequence']
    y = Data_1[i]['Produced']
    s,p = pearsonr(x, y)
    if s < 0.6:
        print('Participant:'+str(i)+'_'+str(s))
        print(csv_files[i])

#%% delate poor coorelation
#%% Learning effect test
for i in range(number_sub):
    x = Data_1[i]['trial']
    y = abs(Data_1[i]['Error'])/Data_1[i]['sequence']
    s,p = scipy.stats.pearsonr(x,y)
    print('Participant:'+str(i)+'_'+str(s))
    if p < 0.05:
        if abs(s) > 0.3:
            print(csv_files[i]+':'+str(p))
            (x*y).mean()
            x.mean()* y.mean()
            pow(x,2).mean()
            pow(x.mean(),2)
            # m 分子是 xy 的均值减去 x 的均值乘以 y 的均值；
            # m 分母是 x 平方的均值 减去 x 的均值的平方
            m = ((x*y).mean() - x.mean()* y.mean())/(pow(x,2).mean()-pow(x.mean(),2))
            c = y.mean() - m*x.mean()
            plt.scatter(x,y,s=30,c="red",marker="o")
            x=np.arange(0.0,80.0,0.1)
            y=m*x+c    
            plt.plot(x,y)
            plt.xlabel('Trial')
            plt.ylabel('Reproduction(s)')  
            plt.title('Learning effect')
            plt.show()
    
# del Data_1[21]
# Data_1[21] = Data_1.pop(number_sub)
# number_sub = number_sub -1
#%% chosing date in each condition
Data_condition = {}
for i in range(number_sub):
    Data_condition[i]={}
for i in range(number_sub):
    Data_condition[i]['1_s']= Data_1[i].loc[(Data_1[i]['sequence'] == 1.04) & (Data_1[i]['retention'] == 1.04)].reset_index()
    Data_condition[i]['1_l']= Data_1[i].loc[(Data_1[i]['sequence'] == 2.08) & (Data_1[i]['retention'] == 2.08)].reset_index()
    Data_condition[i]['2_s']= Data_1[i].loc[(Data_1[i]['sequence'] == 0.52) & (Data_1[i]['retention'] == 1.04)].reset_index()
    Data_condition[i]['2_l']= Data_1[i].loc[(Data_1[i]['sequence'] == 1.04) & (Data_1[i]['retention'] == 2.08)].reset_index()
        
#%%
keys = list(Data_condition[0].keys())
print(keys)

#%% caculate reation time
for i in range(number_sub):
    for key in keys:
        Data_condition[i][key]['Raction_time'] = Data_condition[i][key]['Produced_id_1'] - Data_condition[i][key]['retention_over'] 
        
#%%
def plot_box(n):
    plt.xlim((0.5, 3))
    plt.ylim((-1, 1))
    datas = [Data_condition[n]['1_s']['Error'],Data_condition[n]['2_s']['Error']]
    datal = [Data_condition[n]['1_l']['Error'],Data_condition[n]['2_l']['Error']]
    plt.boxplot(datas, patch_artist = True,positions=(1,1.5),widths=0.3)
    plt.boxplot(datal, patch_artist = True,positions=(2,2.5),widths=0.3)
    x_positions = [1.25,2.25]
    x_name = ['Short','Long']
    plt.xticks(x_positions, x_name)
    plt.xlabel('Ratio')
    plt.ylabel('Reproduction(s)')  
    plt.suptitle('Participant-'+str(n))
    plt.show()  
#%%
for i in range(number_sub):    
    plot_box(i)
# import pickle
# with open('0201_origin.pkl', 'wb') as f:
#     pickle.dump(Data_condition,f,protocol=pickle.HIGHEST_PROTOCOL)
#%%  IOR
def find_out(data):
    Q1 = data.quantile(q = 0.25)
    Q3 = data.quantile(q = 0.75)
    low_whisker = Q1 - 1.5*(Q3 - Q1)
    up_whisker = Q3 + 1.5*(Q3 - Q1)
    out = data[(data > up_whisker) | (data < low_whisker)].index
    return out
#%% find outliear
out75_index = {}
for i in range(number_sub):
    out75_index[i] ={} 
for i in range(number_sub):
    for key in keys:
       temp = find_out(Data_condition[i][key]['Error']).tolist()
       if temp:
           out75_index[i][key]=temp 
           
#%%
out_data2 = {}
for i in range(number_sub):
     out_data2[i] = {}
     if out75_index[i]:
         for key in out75_index[i].keys():
             print(key)
             out_data2[i][key] = Data_condition[i][key]
             ind = out75_index[i][key] 
             print(ind)
             Data_condition[i][key]= out_data2[i][key].drop(ind)   
             
#%%
for i in range(0,number_sub):
    length = 0
    for key in keys:
        t = len(Data_condition[i][key])
        # print(t)
        length = length + t
    print('participant:'+str(i)+':'+str(length))  

#%%
for i in range(number_sub):
    for key in keys:
        Data_condition[i][key] = Data_condition[i][key].reset_index(drop=True)
        
#%% 
print(csv_files[7])    
 
#%% plot the distribution of each condition, all participants
# red is ratio 1, blue is ratio 2; light is short, dark is long.
# lightgreen 1_s 1.04-1.04,  darkgreen 1_l 2.08-2.08, lightblue 2_s 0.52-1.04, darkblue 2_l 1.04-2.08.
def plot_test_distributions(data,conditions,label,i):
    sns.histplot(data[conditions[0]][label],color='lightcoral',label = conditions[0],kde=True,stat="density", linewidth=0,kde_kws=dict(cut=3),alpha=.4)
    sns.histplot(data[conditions[1]][label],color='darkred',label = conditions[1],kde=True, stat="density", linewidth=0,kde_kws=dict(cut=3),alpha=.4 )
    sns.histplot(data[conditions[2]][label],color='lightskyblue',label = conditions[2],kde=True, stat="density", linewidth=0,kde_kws=dict(cut=3),alpha=.4 )
    sns.histplot(data[conditions[3]][label],color='dodgerblue',label = conditions[3],kde=True, stat="density", linewidth=0,kde_kws=dict(cut=3),alpha=.4 )
    plt.axvline(0.52,color='grey')
    plt.axvline(1.04,color='grey')
    plt.axvline(2.08,color='grey')
    plt.title('Density plot -participant:'+str(i))
    plt.legend()
    plt.show()   
    
plot_test_distributions(Data_condition[7],conditions,'Produced',7)

#%% plot each participant produced duration
conditions = ['1_s','1_l','2_s','2_l']
for i in range(number_sub):
    plot_test_distributions(Data_condition[i],conditions,'Produced',i) 
#%%
for i in range(number_sub):
    plot_test_distributions(Data_condition[i],conditions,'Raction_time',i)   
#%% test each participant, each condition
for i in range(number_sub):
    for key in keys:
        s,p = stats.shapiro(Data_condition[i][key]['Error'])
        if p < 0.05:
            print('Participant-'+str(i))
            print(key+':'+ str(p))  
            
#%% 15 performance bad
print(csv_files[14])
 
#%% 
plot_test_distributions(Data_condition[5],conditions,'Error',0)  
 
#%% plot scatter
# blue is ratio 1, green is ratio 2; light is short, dark is long.
def plot_scatter_one(data,conditions,i):
    # fig = plt.figure(1,figsize=[5,5])
    plt.xlim((0, 2.5))
    plt.ylim((0, 3))
    # plt.scatter(1.04,np.mean(Data_condition[i][conditions[0]]['Produced']),color='r')

    plt.scatter(data[conditions[0]]['sequence'],data[conditions[0]]['Produced'],color='lightcoral',alpha = 0.15)
    plt.scatter(data[conditions[1]]['sequence'],data[conditions[1]]['Produced'],color='darkred',alpha = 0.15)
    plt.scatter(data[conditions[2]]['sequence'],data[conditions[2]]['Produced'],color='lightskyblue',alpha = 0.15)
    plt.scatter(data[conditions[3]]['sequence'],data[conditions[3]]['Produced'],color='dodgerblue',alpha = 0.15)
    
    plt.scatter(1.04,np.mean(data[conditions[0]]['Produced']),color='lightcoral',marker='s',label='1-s')
    plt.scatter(2.08,np.mean(data[conditions[1]]['Produced']),color='darkred',marker='s',label='1-l')
    plt.scatter(0.52,np.mean(data[conditions[2]]['Produced']),color='lightskyblue',marker='s',label='2-s')
    plt.scatter(1.04,np.mean(data[conditions[3]]['Produced']),color='dodgerblue',marker='s',label='2-l')
     
    y_best= np.arange(0,2.5,0.2)
    x_best = y_best
    plt.plot(x_best,y_best,color='y',linestyle='dashed')
    plt.legend()
    plt.xlabel('Target duration')
    plt.ylabel('Produced duration')
    plt.title('Original plot - participant:6')
    plt.show()
    
plot_scatter_one(Data_condition[6], conditions, 0) 
#%%  
for i in range(number_sub):
    plot_scatter_one(Data_condition[i], conditions, i)
    
#%%  remove bad participants
# Data_condition.pop(6)
# Data_condition.pop(10)
# Data_condition.pop(16)
# # Data_condition.pop(3)
# # Data_condition.pop(9)
# number_sub = number_sub -3

#%% Calculate decription statics
#  Produce mean,std,cv
def CV(data):
    mean = np.mean(data)
    std = np.std(data, ddof =0)
    cv= std/mean
    return mean,cv
col = ['Sub','Ratio','Length','Mean','R_Mean','CV','BIAS','Std','VAR','R_Std','RMSE','M_Std','M_rec']
Data_descrip={}
for key in keys:
    Data_descrip[key] = pd.DataFrame(index=range(number_sub),columns=col)
    
#%%
for i in range(number_sub):
    for key in keys:
        Data_descrip[key].loc[i,'Sub']= str(i+1)
        if '1' in key:
            Data_descrip[key]['Ratio'] = '1'
        if '2' in key:
            Data_descrip[key]['Ratio'] = '2'
        if 's' in key:
            Data_descrip[key]['Length'] = 'S'
        if 'l' in key:
            Data_descrip[key]['Length'] = 'L'
            
        Data_descrip[key].loc[i,'BIAS'] = np.mean(Data_condition[i][key]['Error']) #mean of error
        Data_descrip[key].loc[i,'Std'] = np.std(Data_condition[i][key]['Error']) #std of error
        Data_descrip[key].loc[i,'VAR'] = np.var(Data_condition[i][key]['Error']) #variance of error
        Data_descrip[key].loc[i,'R_Std'] = np.std(Data_condition[i][key]['Error']/Data_condition[i][key]['sequence']) # std of relative_error
        
        x = np.sqrt(mean_squared_error(Data_condition[i][key]['sequence'], Data_condition[i][key]['Produced']))
        Data_descrip[key].loc[i,'RMSE'] = x
        mean,c = CV(Data_condition[i][key]['Produced'])
        Data_descrip[key].loc[i,'Mean'] = mean #mean of produced
        Data_descrip[key].loc[i,'M_Std'] = np.std(Data_condition[i][key]['Error']/mean)
        Data_descrip[key].loc[i,'R_Mean']= mean/(Data_condition[i][key]['sequence'].loc[0]) #mean of relative_produced
        Data_descrip[key].loc[i,'CV'] = c
        Data_descrip[key].loc[i,'M_rec'] = np.mean(Data_condition[i][key]['Raction_time'])

# with open('0201_descrip.pkl', 'wb') as f:
#     pickle.dump(Data_descrip,f,protocol=pickle.HIGHEST_PROTOCOL)

#%%
result = [Data_descrip[key] for key in keys]
Data_all = pd.concat(result)
#%% check 
# Data_1[i].loc[(Data_1[i]['sequence'] == 1.04) & (Data_1[i]['retention'] == 1.04)]
print(Data_descrip['1_s']['RMSE'][0]** 2 )
print(Data_descrip['1_s']['Std'][0]** 2 + Data_descrip['1_s']['BIAS'][0]** 2)

#%% plot scatter all
fig = plt.figure(2,figsize=[5,5])
plt.xlim((0, 2.5))
plt.ylim((0, 3))
# plt.scatter(1.04,np.mean(Data_condition[i][conditions[0]]['Produced']),color='r')
data1 = Data_all['Mean'].loc[(Data_all['Ratio']=='1')&(Data_all['Length']=='S')]
data2 = Data_all['Mean'].loc[(Data_all['Ratio']=='1')&(Data_all['Length']=='L')]
data3 = Data_all['Mean'].loc[(Data_all['Ratio']=='2')&(Data_all['Length']=='S')]
data4 = Data_all['Mean'].loc[(Data_all['Ratio']=='2')&(Data_all['Length']=='L')]
plt.scatter([1.04 for i in range(number_sub)],data1,color='lightcoral',alpha = 0.1)
plt.scatter([2.08 for i in range(number_sub)],data2,color='darkred',alpha = 0.1)
plt.scatter([0.52 for i in range(number_sub)],data3,color='lightskyblue',alpha = 0.1)
plt.scatter([1.04 for i in range(number_sub)],data4,color='dodgerblue',alpha = 0.1)


plt.scatter(2.08,np.mean(data2),color='darkred',marker='o',label='1-l')
plt.scatter(0.52,np.mean(data3),color='lightskyblue',marker='o',label='2-s')
plt.scatter(1.04,np.mean(data4),color='dodgerblue',marker='o',label='2-l')
plt.scatter(1.04,np.mean(data1),color='lightcoral',marker='o',label='1-s')
 
y_best= np.arange(0,2.5,0.2)
x_best = y_best
plt.plot(x_best,y_best,color='y',linestyle='dashed')
plt.legend()
plt.xlabel('Target duration')
plt.ylabel('Produced duration')
plt.title('Original plot - all participants' ) 
plt.show()

#%% plot all participant descrip results with error bar
def plot_box(data,conditions,label):
    fig = plt.figure(2,figsize=[5,5])
    plt.xlim((0.75, 2.5))
    # plt.ylim((0, 1.5))
    plt.ylim((0.05, 0.2))
    # x_11 = [[1.04 for i in range(number_sub)],[2.08 for i in range(number_sub)]]
    # y_11 = [data[conditions[1]][label].tolist(),data[conditions[2]][label].tolist()]
    # x_21= [[1.04 for i in range(number_sub)],[2.08 for i in range(number_sub)]]
    # y_21 = [data[conditions[0]][label].tolist(),data[conditions[3]][label].tolist()]
    # # plt.scatter(x_11,y_11,color='red',alpha= 0.4)
    # plt.scatter(x_21,y_21,color='blue',alpha= 0.4)
    
    x_2 = [1.04,2.08]
    y_2= [np.mean(data[conditions[2]][label]),np.mean(data[conditions[3]][label])]
    std_2 = [np.std(data[conditions[2]][label])/np.sqrt(number_sub-1),np.std(data[conditions[3]][label])/np.sqrt(number_sub-1)]
    plt.errorbar(x_2,y_2,fmt="bo:",yerr=std_2,label = 'Ratio = 2')
    # blue is ratio = 2, is less precise, ; red is ratio = 1 
    x_1 = [1.04,2.08]
    y_1 = [np.mean(data[conditions[0]][label]),np.mean(data[conditions[1]][label])]
    std_1 = [np.std(data[conditions[0]][label])/np.sqrt(number_sub-1),np.std(data[conditions[1]][label])/np.sqrt(number_sub-1)]
    plt.errorbar(x_1,y_1,fmt = 'ro:',yerr=std_1,label = 'Ratio = 1')
 
    # plt.title('Peproduced durations')
    plt.ylabel('Reaction time of reproduction(s)')
    plt.xlabel('Length of retention')
    plt.legend()
    # plt.savefig('Peproduced durations-'+label+'.png')
    plt.show()
    
#%% plot decription data
plot_box(Data_descrip,conditions,'CV')
# plot_box(Data_descrip,conditions,'M_rec')
# plot_box(Data_descrip,conditions,'R_Std')

#%% data anova
def save_data(name):
    Data_anova = pd.DataFrame(index=range(number_sub),columns=['Subject','1_s','1_l','2_s','2_s'])
    Data_anova['Subject'] = Data_descrip['1_s']['Sub']
    Data_anova['1_s'] = Data_descrip['1_s'][name]
    Data_anova['1_l'] = Data_descrip['1_l'][name]
    Data_anova['2_s'] = Data_descrip['2_s'][name]
    Data_anova['2_l'] = Data_descrip['2_l'][name]
    Data_anova.to_csv(path+'/Data_analysis_1_'+name+'.csv')
save_data('CV')

#%%  plt.boxplot for cv of all participants to detect outlinear
plt.xlim((0.5, 3))
# plt.ylim((0, 0.4))
datas = [Data_descrip['1_s']['CV'],Data_descrip['2_s']['CV']]
datal = [Data_descrip['1_l']['CV'],Data_descrip['2_l']['CV']]
plt.boxplot(datas, patch_artist = True,positions=(1,1.25),widths=0.3)
plt.boxplot(datal, patch_artist = True,positions=(2.25,2.5),widths=0.3)
x_positions = [1.25,2.5]
x_name = ['Short','Long']
plt.xticks(x_positions, x_name)
plt.xlabel('Ratio')
plt.ylabel('Reproduction(s)')  
plt.show()  

#%% violinplot - cv
# 'Sub','Ratio','Length','Mean','R_Mean','CV','BIAS','Std','VAR','R_Std','RMSE','M_Std','M_rec'
Data_all['CV'] = Data_all['CV'].astype(float)
sns.violinplot(x ='Length',y='CV', hue = 'Ratio',data=Data_all,palette='muted', split=True,scale="count", inner="quartile")
#%% violinplot - response time
Data_all['M_mean'] = Data_all['M_rec'].astype(float)
sns.violinplot(x ='Length',y='M_rec', hue = 'Ratio',data=Data_all,palette='muted', split=True,scale="count", inner="quartile")
#%% find out linear participants
out75_index_sub = {}
for key in keys:
    temp = find_out(Data_descrip[key]['CV']).tolist()
    if temp:
        out75_index_sub[key]=temp 
        
#%% delect  outlinear participant
for key in keys:
    Data_descrip[key] = Data_descrip[key].drop([0,11,15])
     
#%%
Data_all.to_csv(path+'/Data_all_1.csv')

#%% Anova TEST
from statsmodels.formula.api import ols
# from statsmodels.stats.anova import anova_lm
from statsmodels.stats.anova import AnovaRM
data = [Data_descrip['1_s']['CV'],Data_descrip['1_l']['CV'],Data_descrip['2_s']['CV'],Data_descrip['2_s']['CV']]
w, p = stats.levene(*data)
if p < 0.05:
    print('no variance chi-squared')
else:
    print('variance chi-squared：'+ str(p))
    
#%% test the distribution of each condition, all participants
# func = lambda x: [y for l in x for y in func(l)] if type(x) is list else [x]
for key in keys:
    # print(stats.kstest(Data_descrip[key]['CV'], 'norm'))
    print(key)
    s,p = stats.shapiro(Data_descrip[key]['CV'])
    if p < 0.05:
        print('no normal distribution')
    else:
        print('normal distribution：'+ str(p))
    # print(stats.anderson(Data_descrip[key]['CV'], 'norm'))
    # AndersonResult(statistic=0.18097695613924714, critical_values=array([0.555, 0.632, 0.759, 0.885, 1.053]), significance_level=array([15. , 10. ,  5. ,  2.5,  1. ]))

#%% Anova test
# Compute the two-way mixed ANOVA and export to a .csv file
Data_all['CV'] = Data_all['CV'].astype(float)
aov = pg.rm_anova(dv='CV', within=['Length','Ratio'],subject='Sub', data=Data_all)
pg.print_table(aov)

#%%
# from statsmodels.formula.api import ols
from statsmodels.stats.anova import AnovaRM
model = AnovaRM(data=Data_all,depvar='CV',subject ='Sub', within = ['Length','Ratio']).fit()
# anova_table = anova_lm(model)
# print(anova_table)

#%%
# estimate sample size via power analysis
from statsmodels.stats.power import FTestPower
# parameters for power analysis
effect = 0.8
alpha = 0.05
power = 0.8
# perform power analysis
FTestPower().solve_power(effect, power=power, nobs=None, ratio=1.0, alpha=alpha)
print('Sample Size: %.3f' % result)
# calculate power curves from multiple power analyses
# FTestPower().plot_power(dep_var='nobs', nobs=arrange(5, 100), effect_size=array([0.2, 0.5, 0.8]))
#%%
# calculate power curves for varying sample and effect size
from numpy import array
from matplotlib import pyplot
from statsmodels.stats.power import TTestIndPower
# parameters for power analysis
effect_sizes = array([0.2, 0.5, 0.8])
sample_sizes = array(range(5, 100))
# calculate power curves from multiple power analyses
analysis = TTestIndPower()
analysis.plot_power(dep_var='nobs', nobs=sample_sizes, effect_size=effect_sizes)
pyplot.show()

#%% plot decription data
def plot_one_condition(label,i):
    fig = plt.figure(1,figsize=[5,5])
    plt.xlim((0, 2.5))
    plt.ylim((0, 0.3))
     
    plt.scatter(1.04,Data_descrip['1_s'][label][i],color='g',alpha= 0.4,label='ratio=1',)
    plt.scatter(1.04,Data_descrip['2_s'][label][i],color='b',alpha= 0.4,label='ratio=2')
    plt.scatter(2.08,Data_descrip['1_l'][label][i],color='g',alpha= 0.9)
    plt.scatter(2.08,Data_descrip['2_l'][label][i],color='b',alpha= 0.9)
    plt.xlabel('Retention interval')
    plt.ylabel('Precision')
    plt.legend()
    plt.title('Peproduced durations(mean)-'+label+'-'+str(i+1))
    # plt.savefig('Peproduced durations(mean).png')
    plt.show()
    
#%%
for i in range(number_sub):
    plot_one_condition('M_Std',i)
    
#%% plot distribution of normal distribution.
u = 0   # 均值μ
sig = math.sqrt(1)  # 标准差δ
x = np.linspace(u - 3*sig, u + 3*sig, 50)   # 定义域
y = np.exp(-(x - u) ** 2 / (2 * sig ** 2)) / (math.sqrt(2*math.pi)*sig) # 定义曲线函数
plt.plot(x, y, "g", linewidth=2)    # 加载曲线
plt.grid(True)  # 网格线
plt.show()
#%% reformulate data
# col = [val for val in ['s','l'] for i in range(5)
data_test = {}
for i in range(number_sub):
    data_test[i] ={}
    for ind in col:
        data_test[i][ind]=pd.DataFrame(columns=['one','two'],index=['s','l'])
        data_test[i][ind].index = pd.Index(['one','two'],name='Ratio')
        data_test[i][ind].columns = pd.Index(['s','l'],name='Length')
# data_test[1].loc['one','s']=1
#%%
for i in range(number_sub):
    for ind in col:
        for key in keys:
            if '1_s' in key:
                data_test[i][ind].loc['one','s']= Data_descrip[key][ind][i] 
            elif '1_l' in key:
                data_test[i][ind].loc['one','l']= Data_descrip[key][ind][i] 
            elif '2_s' in key:
                data_test[i][ind].loc['two','s']= Data_descrip[key][ind][i] 
            elif '2_l' in key:
                data_test[i][ind].loc['two','l']= Data_descrip[key][ind][i] 
        data_test[i][ind] = data_test[i][ind].stack().reset_index().rename(columns={0:ind})  
# data_test[0].info()

#%% organize data
data_anova={}
for i in range(number_sub):
    data_anova[i] = pd.concat([data_test[i][ind] for ind in col],axis=1)
    data_anova[i] = data_anova[i].T.drop_duplicates().T  
Data_anova = pd.concat([data_anova[i] for i in range(number_sub)],axis=0)

for ind in col:
    Data_anova[ind] = Data_anova[ind].astype('float64')
Data_anova.info()




#%%
fig = plt.figure(2,figsize=[5,5])
plt.xlim((0.5, 2.5))
plt.ylim((0, 0.4))
# x_1 = [[1.04 for i in range(5)]),[2.08 for i in range(5)]]
# y_1 = [s_2['CV'],l_2['CV']]
# x_2 = [[1.04 for i in range(5)],[2.08 for i in range(5)]]
# y_2 = [s_1['CV'],l_1['CV']]
# plot_scatter_conditon(y_1,y_2)
# plot_scatter_conditon(y_1,y_2)
x_1 = [1.04,2.08]
y_1 = [np.mean(s_2['CV']),np.mean(l_2['CV'])]
std_1 = [np.std(s_2['CV'])/np.sqrt(number_sub),np.std(l_2['CV'])/np.sqrt(number_sub)]
plt.errorbar(x_1,y_1,fmt = 'go:',yerr=std_1)
 
x_2 = [1.04,2.08]
y_2 = [np.mean(s_1['CV']),np.mean(l_1['CV'])]
std_2 = [np.std(s_1['CV'])/np.sqrt(number_sub),np.std(l_1['CV'])/np.sqrt(number_sub)]
plt.errorbar(x_2,y_2,fmt="bo:",yerr=std_2)
plt.title('Peproduced durations(CV)')
plt.ylabel('Error of reproduction(a.u)')
plt.xlabel('Length of retention')
plt.savefig('Peproduced durations(CV).png')
plt.show()




