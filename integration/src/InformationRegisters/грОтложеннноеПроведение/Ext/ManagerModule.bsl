﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
Процедура ОчиститьЗаписиПоДокументу(СсылкаНаОбъект) Экспорт
	
	НаборЗаписей = РегистрыСведений.грОтложеннноеПроведение.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Документ.Установить(СсылкаНаОбъект);
	
	НаборЗаписей.Записать();
	
КонецПроцедуры
	
#КонецЕсли
