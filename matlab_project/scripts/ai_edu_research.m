%% АНАЛИЗ НА СТУДЕНТСКИТЕ ВЪЗПРИЯТИЯ ЗА ИИ
% Скрипт за анализ и визуализация на данни с MATLAB

%% 0. Начална настройка
clear; clc; close all;
% Зареждаме данните, като оставяме MATLAB да коригира имената по подразбиране
T = readtable('../dataset/ai_in_edu_dataset.csv');

%% 1. Предварителна обработка и преименуване на колоните

% Дефинираме старите (автоматично генерирани) и новите (удобни) имена
oldNames = {'Q1_AI_knowledge', 'Q2_1_Internet', 'Q2_2_Books_Papers', 'Q2_3_Social_media', 'Q2_4_Discussions', 'Q2_5_NotInformed', ...
            'Q3_1_AI_dehumanization', 'Q3_2_Job_replacement', 'Q3_3_Problem_solving', 'Q7_Utility_grade', ...
            'Q9_Advantage_learning', 'Q10_Advantage_evaluation', 'Q11_Disadvantage_educational_process', ...
            'Q12_Gender', 'Q13_Year_of_study', 'Q14_Major', 'Q16_GPA'};
        
newNames = {'Knowledge', 'Source_Internet', 'Source_Books', 'Source_SocialMedia', 'Source_Discussions', 'Source_NotInformed', ...
            'Attitude_Dehumanization', 'Attitude_JobReplacement', 'Attitude_ProblemSolving', 'Utility', ...
            'Advantage_Learning', 'Advantage_Evaluation', 'Disadvantage_Process', ...
            'Gender', 'Year', 'Major', 'GPA_original'};

% Преименуваме колоните
T = renamevars(T, oldNames, newNames);

% Преобразуване на категорийни променливи
T.Gender = categorical(T.Gender, [1 2], {'Жена', 'Мъж'});
T.Year = categorical(T.Year, [2 3], {'2-ри курс', '3-ти курс'});
T.Major = categorical(T.Major, [1 2 3], {'Икономическа кибернетика', 'Статистика', 'Икономическа информатика'});

% *** НАЧАЛО НА КОРЕКЦИЯТА ЗА GPA ***
% Данните в колоната GPA_original вече са числа. Просто трябва да сменим 0 с NaN.
T.GPA = T.GPA_original; 
% Стойностите, които са 0, третираме като липсващи данни (NaN).
T.GPA(T.GPA == 0) = NaN;
% *** КРАЙ НА КОРЕКЦИЯТА ЗА GPA ***


%% 2. Генериране на графики

%% --- Фигура 1: Демографски профил ---
figure('Name', 'Демографски профил', 'Position', [100, 100, 1200, 400]);
subplot(1,3,1); pie(T.Gender); title('Разпределение по пол');
subplot(1,3,2); pie(T.Year); title('Разпределение по курс');
subplot(1,3,3); pie(T.Major); title('Разпределение по специалност');
sgtitle('Фигура 1: Демографски профил на респондентите', 'FontSize', 14, 'FontWeight', 'bold');

%% --- Фигура 2: Информираност и източници ---
figure('Name', 'Информираност и източници', 'Position', [150, 150, 1000, 450]);
subplot(1,2,1);
histogram(T.Knowledge, 'BinMethod', 'integers', 'FaceColor', '#0072BD');
title('Самооценка на информираността за ИИ'); xlabel('Оценка (1-10)'); ylabel('Брой студенти'); grid on; xlim([0.5 10.5]);
subplot(1,2,2);
sourceData = sum(T{:, {'Source_Internet', 'Source_Books', 'Source_SocialMedia', 'Source_Discussions', 'Source_NotInformed'}});
sourceLabels = {'Интернет', 'Книги/Статии', 'Соц. медии', 'Дискусии', 'Не се информирам'};
b = bar(categorical(sourceLabels), sourceData, 'FaceColor', '#D95319');
text(b.XEndPoints,b.YEndPoints,string(b.YData),'HorizontalAlignment','center','VerticalAlignment','bottom')
title('Източници на информация за ИИ'); ylabel('Брой студенти');
sgtitle('Фигура 2: Информираност и източници на информация', 'FontSize', 14, 'FontWeight', 'bold');

%% --- Фигура 3: Нагласи към твърдения ---
figure('Name', 'Нагласи към ИИ', 'Position', [200, 200, 900, 500]);
q3_vars = T{:, {'Attitude_ProblemSolving', 'Attitude_JobReplacement', 'Attitude_Dehumanization'}};
cat_order = [5, 4, 3, 2, 1]; counts = zeros(3, 5); 
for i = 1:3 
    current_col_data = q3_vars(:,i); 
    for cat_val = 1:5 
        counts(i, cat_val) = sum(current_col_data == cat_val);
    end
end
barh(counts(:, cat_order), 'stacked');
set(gca, 'YTickLabel', {'ИИ помага за решаване на проблеми', 'Роботите ще заместят хората', 'ИИ води до дехуманизация'});
xlabel('Брой отговори'); title('Фигура 3: Съгласие с твърдения за социалното въздействие на ИИ');
legend({'Напълно съгласен', 'Частично съгласен', 'Неутрален', 'Частично несъгласен', 'Напълно несъгласен'}, 'Location', 'eastoutside');
grid on;

%% --- Фигура 4: Корелационна матрица ---
figure('Name', 'Корелационен анализ', 'Position', [250, 250, 600, 500]);
numeric_vars = [T.Knowledge, T.Utility, T.GPA];
R = corrcoef(numeric_vars, 'Rows', 'pairwise'); 
labels = {'Знания за ИИ', 'Полезност на ИИ', 'GPA'};
h = heatmap(labels, labels, R); h.Title = 'Фигура 4: Корелационна матрица'; h.Colormap = summer;

%% --- Фигура 5: Диаграма на разсейване ---
figure('Name', 'Разсейване', 'Position', [300, 300, 700, 500]);
scatter(T.Knowledge, T.Utility, 50, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;
idx = ~isnan(T.Knowledge) & ~isnan(T.Utility);
p = polyfit(T.Knowledge(idx), T.Utility(idx), 1);
x_fit = linspace(min(T.Knowledge(idx)), max(T.Knowledge(idx)), 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, 'r-', 'LineWidth', 2);
title('Фигура 5: Връзка между знания и възприемана полезност на ИИ');
xlabel('Самооценка на знания (1-10)'); ylabel('Оценка за полезност (1-10)');
legend('Данни', 'Линия на тренда', 'Location', 'northwest'); grid on;

%% --- Фигура 6: Предимства и недостатъци в образованието ---
figure('Name', 'ИИ в Образованието', 'Position', [350, 350, 1400, 450]);
subplot(1,3,1);
labels_Q9 = {'Персонализация', 'Универсален достъп', 'Интерактивност', 'Друго'};
C9 = categorical(T.Advantage_Learning, 1:4, labels_Q9, 'Ordinal', true);
histogram(C9); title('Предимство в процеса на учене'); ylabel('Брой отговори'); xtickangle(15);
subplot(1,3,2);
labels_Q10 = {'Автоматизация', 'По-малко грешки', 'Постоянна обратна връзка', 'Друго'};
C10 = categorical(T.Advantage_Evaluation, 1:4, labels_Q10, 'Ordinal', true);
histogram(C10); title('Предимство в процеса на оценяване'); xtickangle(15);
subplot(1,3,3);
labels_Q11 = {'Липса на връзка', 'Интернет зависимост', 'По-рядка интеракция', 'Загуба на данни'};
C11 = categorical(T.Disadvantage_Process, 1:4, labels_Q11, 'Ordinal', true);
histogram(C11); title('Недостатък в образователния процес'); xtickangle(15);
sgtitle('Фигура 6: Основни възприятия за ролята на ИИ в образованието', 'FontSize', 14, 'FontWeight', 'bold');

disp('Скриптът приключи успешно. Всички фигури са генерирани.');