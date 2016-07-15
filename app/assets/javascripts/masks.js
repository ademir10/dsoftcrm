jQuery(function($){
	//MASCARAS PARA O CONTAS Á PAGAR E RECEBER
	
	//NEWLINE
	$("#t").html("#{simple_format title}");
        
      
   //carregar o calendário contas a pagar em portugues
   $(document).ready(function () {
        $('#data_vencto_pagar').datepicker({format: "dd/mm/yyyy", language: "pt-BR" });
      });
   $(document).ready(function () {
        $('#data_pagto').datepicker({format: "dd/mm/yyyy", language: "pt-BR" });
      });   
   //-------------------------------
   
   //carregar o calendário contas a receber em portugues
   $(document).ready(function () {
        $('#data_vencto_receb').datepicker({format: "dd/mm/yyyy", language: "pt-BR" });
      });
   $(document).ready(function () {
        $('#data_receb').datepicker({format: "dd/mm/yyyy", language: "pt-BR" });
      });   
   //-------------------------------
   
   //valores no cadastro de produtos
   $("#cost_value").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#cost_sale").maskMoney({symbol:"R$",decimal:".",thousands:""});
   //-------------------------------
   
   //valores no cadastro de taxas
   $("#pis").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#icms").maskMoney({symbol:"R$",decimal:".",thousands:""});
   //-------------------------------
     
   //-------------------------------
   
   $("#phone").mask("(99) 9999-9999",{placeholder:""});
   $("#phone1").mask("(99) 9999-9999",{placeholder:""});
   $("#celphone").mask("(99)99999-9999", {placeholder:""});
   $("#cep").mask("99999-999",{placeholder:""});
   $("#cpf").mask("999.999.999-99",{placeholder:" "});
   $("#cnpj").mask("99.999.999/9999-99",{placeholder:" "});
   //Faz a mascara de moeda do Brasil
   //maskMoney({symbol:"R$",decimal:",",thousands:"."})
   $("#real").maskMoney({symbol:"R$",decimal:".",thousands:""});
   
   $("#r1").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#r2").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#r3").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#r4").maskMoney({symbol:"R$",decimal:".",thousands:""});
   $("#r5").maskMoney({symbol:"R$",decimal:".",thousands:""});});
   
   $("#total_geral").mask("99.999.999/9999-99",{placeholder:" "});
   
   //deixar tudo em letra maiuscula
   //$(document).ready(function() {
   //$("input").keyup(function(){
   // $(this).val($(this).val().toUpperCase());
   //	});
   //	});
   
