﻿
&НаСервере
Функция ПолучитьДолжностьНаСервере(Сотрудник)
	
	Возврат ПолучениеДанныхНаСервере.ПолучитьДолжностьНаСервере(Сотрудник);
	
КонецФункции

&НаКлиенте
Процедура СотрудникОкладСотрудникПриИзменении(Элемент)
	
	ТекСтрока = Элементы.СотрудникОклад.ТекущиеДанные;
	ТекСтрока.Должность = ПолучитьДолжностьНаСервере(ТекСтрока.Сотрудник);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Автор) Тогда
		Объект.Автор = ПараметрыСеанса.ТекущийПользователь;	
	КонецЕсли; 
	
КонецПроцедуры
