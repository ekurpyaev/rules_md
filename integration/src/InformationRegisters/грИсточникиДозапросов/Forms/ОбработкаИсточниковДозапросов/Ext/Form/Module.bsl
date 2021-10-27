﻿
#Область ПроцедурыИФУнкцииОбщегоНазначения

#Область Интерфейс

&НаСервере
Процедура УстановитьУсловноеОформление()

	грОтложенныеОперацииИнтеграции.УстановитьУсловноеОформление(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура УстановитьВидимостьДоступность()

	Элементы.ОчиститьДозапросыПослеОбработкиПакетов.Доступность = ОбработатьПакеты;

КонецПроцедуры

#КонецОбласти

#Область ДеревоЗаданий

Процедура ЗаполнитьТаблицуИерархияЗаданий(ИдентификаторЗадания, ПараметрыДерева)

	НоваяСтрока = ТаблицаИерархияЗаданий.Добавить();
	НоваяСтрока.ИдентификаторЗадания	= ИдентификаторЗадания;
	НоваяСтрока.Родитель				= ИдентификаторЗадания;
	
	Для каждого Родитель Из ПараметрыДерева.ВышестоящиеРодителиЗадания Цикл
		
		НоваяСтрока = ТаблицаИерархияЗаданий.Добавить();
		НоваяСтрока.ИдентификаторЗадания	= ИдентификаторЗадания;
		НоваяСтрока.Родитель				= Родитель;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьКолонкиТекущиеДанныеДеревоЗаданий(Форма)
	
	ПараметрыДерева = грОтложенныеОперацииИнтеграцииКлиентСервер.ПараметрыДереваЗаданий(Форма);
	
	Колонки			= Форма[ПараметрыДерева.ИмяТаблицыИдентификаторов].Выгрузить().Колонки;
	МассивКолонок	= Новый Массив;
	
	Для каждого Колонка Из Колонки Цикл
		
		
		Если Колонка.Имя = "НомерУровня"
			Или Колонка.Имя = "Идентификатор"
			Тогда 
			Продолжить;
		КонецЕсли;
		
		МассивКолонок.Добавить(Колонка.Имя);
		
	КонецЦикла;
	
	Форма[ПараметрыДерева.ИмяКолонкиТекущиеДанные] = СтрСоединить(МассивКолонок, ",");
	
КонецПроцедуры 

&НаСервере
Функция ФоновыеЗаданияОтменены(МассивЗаданий)

	ЗаданияКОтмене = Новый Массив;
	
	Для каждого Задание Из МассивЗаданий Цикл
		
		Отбор = Новый Структура;
		Отбор.Вставить("Идентификатор", Задание);
		
		НайденныеЗначения = ТаблицаИдентифкаторовДеревоЗаданий.НайтиСтроки(Отбор);
		Если НайденныеЗначения.Количество() Тогда
			
			Если НайденныеЗначения[0].Состояние = Перечисления.грСостоянияФоновыхЗаданий.Активно Тогда
				ЗаданияКОтмене.Добавить(НайденныеЗначения[0].ИдентификаторЗадания);
			КонецЕсли;
		
		КонецЕсли;
		
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТаблицаИерархияЗаданий"	, ТаблицаИерархияЗаданий.Выгрузить());
	Запрос.УстановитьПараметр("ЗаданияКОтмене"			, ЗаданияКОтмене);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТаблицаИерархияЗаданий.ИдентификаторЗадания КАК ИдентификаторЗадания,
		|	ТаблицаИерархияЗаданий.Родитель КАК Родитель
		|ПОМЕСТИТЬ ВТ_ИерархияЗаданий
		|ИЗ
		|	&ТаблицаИерархияЗаданий КАК ТаблицаИерархияЗаданий
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ВТ_ИерархияЗаданий.ИдентификаторЗадания КАК ИдентификаторЗадания
		|ИЗ
		|	ВТ_ИерархияЗаданий КАК ВТ_ИерархияЗаданий
		|ГДЕ
		|	ВТ_ИерархияЗаданий.Родитель В(&ЗаданияКОтмене)";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Результат = Ложь;
	
	Пока Выборка.Следующий() Цикл
		
		ФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(Новый УникальныйИдентификатор(Выборка.ИдентификаторЗадания));
		
		Если Не ФоновоеЗадание = Неопределено Тогда
			
			Если ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
			
				Результат = Истина;
				ФоновоеЗадание.Отменить();
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции // ФоновыеЗаданияОтменены

&НаСервере
Процедура ЗаполнитьДеревоПоТаблицеЗаданий(СтрокаДерева, Таблица, ПараметрыДерева)
	
	Отбор = Новый Структура;
	Отбор.Вставить("ИдентификаторЗаданияРодитель"	, СтрокаДерева.ИдентификаторЗадания);
	Отбор.Вставить("НомерУровня"					, СтрокаДерева.НомерУровня + 1);
	
	НайденныеСтроки = Таблица.НайтиСтроки(Отбор);
	Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
		
		НоваяСтрокаДерева = СтрокаДерева.Строки.Добавить();
		
		Если НайденнаяСтрока.Состояние = Перечисления.грСостоянияФоновыхЗаданий.Активно Тогда
		
			ОтборСтрок = Новый Структура;
			ОтборСтрок.Вставить("ИдентификаторЗадания", НайденнаяСтрока.ИдентификаторЗадания);
			
			СтрокиТаблицыИдентификаторов = ТаблицаИдентифкаторовДеревоЗаданий.НайтиСтроки(ОтборСтрок);
			Если СтрокиТаблицыИдентификаторов.Количество() Тогда
				ЗаполнитьЗначенияСвойств(НоваяСтрокаДерева, СтрокиТаблицыИдентификаторов[0]);
			КонецЕсли;
			
			Для каждого РеквизитДляПроверки Из ПараметрыДерева.ТекущиеДанные Цикл
				
				Если ЗначениеЗаполнено(НайденнаяСтрока[РеквизитДляПроверки.Ключ]) Тогда
					НоваяСтрокаДерева[РеквизитДляПроверки.Ключ] = НайденнаяСтрока[РеквизитДляПроверки.Ключ];
				КонецЕсли;
				
			КонецЦикла;
			
		Иначе
			ЗаполнитьЗначенияСвойств(НоваяСтрокаДерева, НайденнаяСтрока);
		КонецЕсли;
		
		НоваяСтрокаДерева.НомерУровня = НоваяСтрокаДерева.Уровень();
		
		//+ТаблицуИерархияЗаданий
		Если Отбор.НомерУровня = 1 Тогда
			ПараметрыДерева.ВышестоящиеРодителиЗадания.Очистить();
			ПараметрыДерева.ВышестоящиеРодителиЗадания.Добавить(СтрокаДерева.ИдентификаторЗадания);
		КонецЕсли;
		
		ЗаполнитьТаблицуИерархияЗаданий(НоваяСтрокаДерева.ИдентификаторЗадания, ПараметрыДерева);
		
		ПараметрыДерева.ВышестоящиеРодителиЗадания.Добавить(НоваяСтрокаДерева.ИдентификаторЗадания);
		//-ТаблицуИерархияЗаданий
		
		ЗаполнитьДеревоПоТаблицеЗаданий(НоваяСтрокаДерева, Таблица, ПараметрыДерева);
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДеревоЗаданийСервер(ПараметрыДерева = Неопределено)

	Если ПараметрыДерева = Неопределено Тогда
		ПараметрыДерева = грОтложенныеОперацииИнтеграцииКлиентСервер.ПараметрыДереваЗаданий(ЭтаФорма);
	КонецЕсли;
	
	СоответствиеСостоянийФоновыхЗаданий	= грОтложенныеОперацииИнтеграцииКлиентСервер.СоответствиеСостоянийФоновыхЗаданий();
	СоответствиеСостояниеКартинка		= грОтложенныеОперацииИнтеграцииКлиентСервер.СоответствиеСостояниеКартинка();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	грПрогрессОтложенныхОперацийИнтеграции.Ключ КАК Ключ,
		|	грПрогрессОтложенныхОперацийИнтеграции.ИдентификаторЗадания КАК ИдентификаторЗадания,
		|	грПрогрессОтложенныхОперацийИнтеграции.ИдентификаторЗаданияРодитель КАК ИдентификаторЗаданияРодитель,
		|	грПрогрессОтложенныхОперацийИнтеграции.Наименование КАК Наименование,
		|	грПрогрессОтложенныхОперацийИнтеграции.Уровень КАК НомерУровня,
		|	грПрогрессОтложенныхОперацийИнтеграции.Начало КАК Начало,
		|	0 КАК ПроцентВыполнения,
		|	ЗНАЧЕНИЕ(Перечисление.грСостоянияФоновыхЗаданий.ПустаяСсылка) КАК Состояние,
		|	0 КАК СостояниеКартинка
		|ИЗ
		|	РегистрСведений.грПрогрессОтложенныхОперацийИнтеграции КАК грПрогрессОтложенныхОперацийИнтеграции";
	
	ТаблицаЗаданий = Запрос.Выполнить().Выгрузить();
	ТаблицаЗаданий.Колонки.Добавить("Информация", ОбщегоНазначения.ОписаниеТипаСтрока(0));
	
	Для каждого СтрокаТаблицы Из ТаблицаЗаданий Цикл
		
		ИдентификаторЗадания	= Новый УникальныйИдентификатор(СтрокаТаблицы.ИдентификаторЗадания);
		Задание					= ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
		
		Если Задание = Неопределено Тогда
			
			СтрокаТаблицы.Состояние			= Перечисления.грСостоянияФоновыхЗаданий.Отменено;
			СтрокаТаблицы.СостояниеКартинка	= СоответствиеСостояниеКартинка.Получить(СтрокаТаблицы.Состояние);
			Продолжить;
			
		КонецЕсли;
		
		Если Задание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
			
			РезультатВыгрузки = ДлительныеОперации.ПрочитатьПрогресс(ИдентификаторЗадания);
			Если ТипЗнч(РезультатВыгрузки) = Тип("Структура") Тогда
				
				Если РезультатВыгрузки.Свойство("Процент") Тогда
					СтрокаТаблицы.ПроцентВыполнения = РезультатВыгрузки.Процент;
				КонецЕсли;
				
				Если РезультатВыгрузки.Свойство("ДополнительныеПараметры") Тогда
					
					КоличествоОбработано	= РезультатВыгрузки.ДополнительныеПараметры.КоличествоОбработано;
					КоличествоВсего			= РезультатВыгрузки.ДополнительныеПараметры.КоличествоВсего;
					
					СтрокаТаблицы.Информация = СтрШаблон("Обработано: %1 из %2", КоличествоОбработано, КоличествоВсего);
					
				КонецЕсли;
				
			КонецЕсли;
			
		ИначеЕсли Задание.Состояние = СостояниеФоновогоЗадания.Завершено Тогда
			
			СтрокаТаблицы.ПроцентВыполнения = 100;
			
		ИначеЕсли Задание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно 
			Или Задание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
			
			СтрокаТаблицы.Информация = ПодробноеПредставлениеОшибки(Задание.ИнформацияОбОшибке);
			
		КонецЕсли;
		
		СтрокаТаблицы.Состояние			= СоответствиеСостоянийФоновыхЗаданий.Получить(Задание.Состояние);
		СтрокаТаблицы.СостояниеКартинка	= СоответствиеСостояниеКартинка.Получить(СтрокаТаблицы.Состояние);
		
	КонецЦикла;
	
	ТаблицаНулевогоУровня = ТаблицаЗаданий.Скопировать(Новый Структура("НомерУровня", 0));
	
	Дерево = РеквизитФормыВЗначение(ПараметрыДерева.ИмяДерева);
	Дерево.Строки.Очистить();
	
	ТаблицаИерархияЗаданий.Очистить();
	
	Для каждого СтрокаТаблицы Из ТаблицаНулевогоУровня Цикл
		
		НоваяСтрокаДерева = Дерево.Строки.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрокаДерева, СтрокаТаблицы);
		
		ВышестоящиеРодителиЗадания = Новый Массив;
		ВышестоящиеРодителиЗадания.Добавить(СтрокаТаблицы.ИдентификаторЗадания);
		
		ПараметрыДерева.Вставить("ВышестоящиеРодителиЗадания", Новый Массив);
		
		ЗаполнитьТаблицуИерархияЗаданий(СтрокаТаблицы.ИдентификаторЗадания, ПараметрыДерева);
		
		ЗаполнитьДеревоПоТаблицеЗаданий(НоваяСтрокаДерева, ТаблицаЗаданий, ПараметрыДерева);
		
	КонецЦикла; 
	
	Дерево.Строки.Сортировать("Начало", Истина);
	
	ТаблицаИерархияЗаданий.Сортировать("Родитель, ИдентификаторЗадания");
	
	ЗначениеВРеквизитФормы(Дерево, ПараметрыДерева.ИмяДерева);
	
	ЭтаФорма[ПараметрыДерева.ИмяТаблицыИдентификаторов].Очистить();
	
	грРаботаСДеревомСервер.ЗаполнитьТаблицуИдентификаторовРекурсией(
		ЭтаФорма[ПараметрыДерева.ИмяТаблицыИдентификаторов],
		ЭтаФорма[ПараметрыДерева.ИмяДерева].ПолучитьЭлементы());
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДеревоЗаданий(ПараметрыДерева = Неопределено)
	
	Если ПараметрыДерева = Неопределено Тогда
		ПараметрыДерева = грОтложенныеОперацииИнтеграцииКлиентСервер.ПараметрыДереваЗаданий(ЭтаФорма);
	КонецЕсли;
	
	ЗаполнитьДеревоЗаданийСервер(ПараметрыДерева);
	
	грРаботаСДеревомКлиент.РазвернутьВсеВеткиДерева(ЭтаФорма, ПараметрыДерева.ИмяДерева);

	ПараметрыУстановкиТекущейСтроки = Новый Структура;
	ПараметрыУстановкиТекущейСтроки.Вставить("ИмяДерева"					, ПараметрыДерева.ИмяДерева);
	ПараметрыУстановкиТекущейСтроки.Вставить("ИмяТаблицыИдентификаторов"	, ПараметрыДерева.ИмяТаблицыИдентификаторов);
	ПараметрыУстановкиТекущейСтроки.Вставить("ОтборТаблицыИдентификаторов"	, Новый Структура("ИдентификаторЗадания", ИдентификаторЗаданияТекущейСтроки));
	
	грРаботаСДеревомКлиент.УстановитьТекущуюСтроку(
		ЭтаФорма,
		ПараметрыУстановкиТекущейСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПроверитьВыполнениеЗадания()
	
	ЗаполнитьДеревоЗаданий();
	
	Если Не ПериодичностьОбновленияДерева = 0 Тогда
		ПодключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания", ПериодичностьОбновленияДерева, Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область Прочее

&НаСервере
Процедура ЗапуститьОтменитьЗадания()
	
	НаименованияДляОчисткиФоновыхЗаданий = Новый Соответствие;
	
	ПараметрыЗапускаРегламентныхЗаданий = грОтложенныеОперацииИнтеграцииКлиентСервер.ПараметрыЗапускаРегламентныхЗаданий();
	Для каждого Параметр Из ПараметрыЗапускаРегламентныхЗаданий Цикл
		
		Если ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(ЭтотОбъект, Параметр.Значение.ИмяМетода) Тогда
			
			Если Параметр.Ключ = Перечисления.грМетодыОтложенныхОперацийИнтеграции.ОчиститьОтложенныеДозапросы Тогда
				Продолжить;
			КонецЕсли;
			
			Если ЭтотОбъект[Параметр.Значение.ИмяМетода] Тогда
				
				Ключ			= Параметр.Значение.Наименование;
				Наименование	= Ключ;
				
				ПараметрыПорций	= Новый Структура;
				ПараметрыПорций.Вставить("Размер"		, РазмерПорции);
				ПараметрыПорций.Вставить("Количество"	, КоличествоОбъектов);
				
				Параметр.Значение.Вставить("ПараметрыПорций", ПараметрыПорций);
				Параметр.Значение.Вставить("ДобавитьПараметрыПорцийВНаименование");
				
				Отборы = Новый Структура;
				Если Параметр.Значение.Операция = Перечисления.грОтложенныеОперацииИнтеграции.ИсточникиДозапросов Тогда
					
					Отборы.Вставить("ТипДозапроса", ОтборТипДозапроса);
					
					ОтборКласс = СокрЛП(ОтборКласс);
					Если ЗначениеЗаполнено(ОтборКласс) Тогда
						Отборы.Вставить("Класс", ОтборКласс);
					КонецЕсли;
					
					Если Параметр.Ключ = Перечисления.грМетодыОтложенныхОперацийИнтеграции.ОбработатьПакеты Тогда
						Параметр.Значение.Вставить("ОчиститьОтложенныеДозапросы", ОчиститьДозапросыПослеОбработкиПакетов);
					КонецЕсли;
				
				КонецЕсли;
				
				Параметр.Значение.Вставить("Отборы", Отборы);
				Параметр.Значение.Вставить("ДобавитьОтборыВНаименование");
				
				ДополнительныеПараметры = Новый Соответствие;
				ДополнительныеПараметры.Вставить(Параметр.Ключ	, Параметр.Значение);
				
				МассивПараметров = Новый Массив;
				МассивПараметров.Добавить(ДополнительныеПараметры);
				
				ДобавитьЗадание = Истина;
				
				Если Параметр.Значение.Операция = Перечисления.грОтложенныеОперацииИнтеграции.ИзменениеОбъектов Тогда
				
					ОтборЗадания = Новый Структура;
					ОтборЗадания.Вставить("Ключ"			, Ключ);
					ОтборЗадания.Вставить("Использование"	, Истина);
					
					НайденныеЗадания = РегламентныеЗаданияСервер.НайтиЗадания(ОтборЗадания);
					Если НайденныеЗадания.Количество() > 0 Тогда
						
						ДобавитьЗадание = Ложь;
						
						ПараметрыЗадания = Новый Структура;
						ПараметрыЗадания.Вставить("Параметры"	, МассивПараметров);
						ПараметрыЗадания.Вставить("Наименование", грОтложенныеОперацииИнтеграции.НаименованиеЗадания(Наименование, Параметр.Значение));
						
						Задание = НайденныеЗадания[0];
						РегламентныеЗаданияСервер.ИзменитьЗадание(Задание, ПараметрыЗадания);
						
					КонецЕсли;
				
				КонецЕсли;
				
				Если ДобавитьЗадание Тогда
				
					ПараметрыЗадания = грОтложенныеОперацииИнтеграции.ПараметрыДобавленияРегламентныхЗаданий();
					ПараметрыЗадания.Ключ			= Ключ;
					ПараметрыЗадания.Параметры		= МассивПараметров;
					ПараметрыЗадания.Наименование	= грОтложенныеОперацииИнтеграции.НаименованиеЗадания(Наименование, Параметр.Значение);
					
					Задание = РегламентныеЗаданияСервер.ДобавитьЗадание(ПараметрыЗадания);
				
				КонецЕсли; 
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры // ЗапуститьРегламентныеЗадания()

&НаСервере
Процедура УстановитьЗначениеКонстанты(Имя, Значение)

	Константы[Имя].Установить(Значение);

КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьУсловноеОформление();
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	КоличествоОбъектов				= сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты( "грКоличествоОбъектовДляОбработкиОтложеннымиОперациямиИнтеграции" );
	РазмерПорции					= сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты( "грРазмерПорцииОтложенныхОперацийИнтеграции" );
	ИнтервалОчисткиПрогресса		= сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты( "грИнтервалОчисткиПрогрессаОтложенныхОперацийИнтеграции" );
	ПериодичностьОбновленияДерева	= сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты( "грПериодичностьОбновленияДереваЗаданийОтложенныхОперацийИнтеграции" );
	
	ОтборТипДозапроса				= Перечисления.грТипыДозапросов.Дозапрос;
	
	ЗаполнитьКолонкиТекущиеДанныеДеревоЗаданий(ЭтаФорма);
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Подключаемый_ПроверитьВыполнениеЗадания();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	ОтключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

#Область Параметры

&НаКлиенте
Процедура КоличествоОбъектовПриИзменении(Элемент)
	
	УстановитьЗначениеКонстанты(
		"грКоличествоОбъектовДляОбработкиОтложеннымиОперациямиИнтеграции",
		КоличествоОбъектов);
	
КонецПроцедуры

&НаКлиенте
Процедура РазмерПорцииПриИзменении(Элемент)
	
	УстановитьЗначениеКонстанты(
		"грРазмерПорцииОтложенныхОперацийИнтеграции",
		РазмерПорции);
	
КонецПроцедуры

&НаКлиенте
Процедура ИнтервалОчисткиПрогрессаПриИзменении(Элемент)
	
	УстановитьЗначениеКонстанты(
		"грИнтервалОчисткиПрогрессаОтложенныхОперацийИнтеграции",
		ИнтервалОчисткиПрогресса);
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодичностьОбновленияДереваПриИзменении(Элемент)
	
	ОтключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания");
	
	УстановитьЗначениеКонстанты(
		"грПериодичностьОбновленияДереваЗаданийОтложенныхОперацийИнтеграции",
		ПериодичностьОбновленияДерева);
		
	Подключаемый_ПроверитьВыполнениеЗадания();
	
КонецПроцедуры

#КонецОбласти

#Область РегламентныеЗадания

&НаКлиенте
Процедура ОбработатьПакетыПриИзменении(Элемент)
	
	Если Не ОбработатьПакеты Тогда
		ОчиститьДозапросыПослеОбработкиПакетов = Ложь;
	КонецЕсли;
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Сохранить(Команда)

	ЗапуститьОтменитьЗадания();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДерево(Команда)
	
	ЗаполнитьДеревоЗаданий();
	
КонецПроцедуры 

&НаКлиенте
Процедура ОчиститьНеАктивныеФоновыеЗадания(Команда)
	грОтложенныеОперацииИнтеграцииВызовСервера.ОчиститьВыключенныеРегламентыеЗадания();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийДеревоЗаданий

&НаКлиенте
Процедура ДеревоЗаданийПриАктивизацииСтроки(Элемент)
	
	ИдентификаторЗаданияТекущейСтроки = Неопределено;
	
	ТекущиеДанные = Элементы.ДеревоЗаданий.ТекущиеДанные;
	Если Не ТекущиеДанные = Неопределено Тогда
		ИдентификаторЗаданияТекущейСтроки = ТекущиеДанные.ИдентификаторЗадания;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОстановитьЗадание(Команда)
	
	ВыделенныеСтроки = Элементы.ДеревоЗаданий.ВыделенныеСтроки;
	
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если ФоновыеЗаданияОтменены(ВыделенныеСтроки) Тогда
	
		ЗаполнитьДеревоЗаданий();
	
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти