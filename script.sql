create database trabalho_bd;
create schema trb;
drop database trabalho_bd;
drop schema trb cascade;

--####################################################TABELA USUARIO#######################################################	
create table trb.usuario(
	user_id serial,
	user_id_telefone integer,
	user_id_endereco integer,
	user_nome varchar(40) not null,
	user_email varchar(40) not null unique,
	user_senha varchar(40) not null,
	user_cpf varchar(11) not null unique,
	user_idade integer not null constraint check_idade check(user_idade >= 18), 
	primary key (user_id),
	foreign key (user_id_telefone) references trb.telefone(tel_id),
	foreign key (user_id_endereco) references trb.endereco(end_id)
);
alter table trb.usuario add user_cpf varchar(11);
select * from trb.usuario;	
drop table trb.usuario;
delete from trb.usuario where user_id >= 4;
insert into trb.usuario(user_nome, user_email, user_senha, user_cpf, user_idade) values('marta','marta@gmail.com', '123','12345678919','23');
insert into trb.usuario(user_nome, user_email, user_senha, user_cpf, user_idade) values('David','david@gmail.com', '123','12345678914','30');
update table trb.usuario(user_id_telefone) values(1);
--################################################FIM TABELA USUARIO########################################################################

--################################################ TABELA telefone##########################################################################
create table trb.telefone(
	tel_id integer not null,
	tel_fixo numeric not null  constraint check_tel_fix check(tel_fixo >= 11),
	tel_celular numeric not null constraint check_tel_celular check(tel_celular >= 11),
	primary key (tel_id)
);
select * from trb.telefone;
drop table trb.telefone cascade;
truncate table trb.telefone;
insert into trb.telefone(tel_id,tel_fixo,tel_celular) values(2,'65999972846','65999972726');
insert into trb.telefone(tel_id) values(6);
insert into trb.telefone(tel_id,tel_fixo,tel_celular) values(2,'99972826','99972827');
--####################################################FIM TABELA TELEFONE#######################################################
create table trb.endereco(
	end_id integer not null unique,
        end_rua varchar(100) not null,
        end_numero varchar(10) not null,
        end_bairro varchar(40) not null,
        end_cep varchar(45) not null,
        end_complemento varchar(45) not null,
        end_referencia varchar(45) not null,
	primary key (end_id)
);
drop table trb.endereco cascade;
select * from trb.endereco;
###########################################################################################################
create table trb.cidade(
	cd_id integer not null unique,
	cd_id_endereco integer not null,
	cd_id_estado integer not null,
	cd_id_pais integer not null,
	cd_nome varchar(45) not null,
	foreign key (cd_id_endereco) references  trb.endereco(end_id),
	foreign key (cd_id_estado) references  trb.estado(es_id),
	foreign key (cd_id_pais) references  trb.pais(ps_id),
	primary key (cd_id)
);
drop table trb.cidade;
############################################################################################################
create table trb.estado(
	es_id integer not null unique,
	es_nome varchar(45) not null,
	primary key (es_id)
);
drop table trb.estado;
select * from trb.estado;
############################################################################################################
create table trb.pais(
	ps_id integer unique not null,
	ps_nome varchar(45) not null,
	primary key(ps_id)
);
drop table trb.pais;
############################################################################################################
create table trb.comprador(
	cp_id serial not null unique,
	cp_id_usuario integer not null,
	primary key (cp_id),
	foreign key(cp_id_usuario) references trb.usuario(user_id)
);
drop table trb.comprador;
select * from trb.comprador;
delete  from trb.comprador as comp where comp.cp_id = 1;
insert into trb.comprador(cp_id_usuario) values(6);
select * from trb.comprador as comp cross join trb.usuario as usr where comp.cp_id_usuario = usr.user_id;
insert into trb.comprador(cp_id_usuario) values(2);
############################################################################################################
create table trb.vendedor(
	vd_id serial not null primary key,
	vd_id_usuario integer not null,
	foreign key(vd_id_usuario) references trb.usuario(user_id)
);
insert into trb.vendedor(vd_id_usuario) values();
select * from trb.vendedor as ven cross join trb.usuario as usr where ven.vd_id_usuario = usr.user_id;
############################################################################################################
create table trb.produto(
	pdt_id serial not null,
	pdt_id_vendedor integer not null,
	pdt_id_categoria integer,
	pdt_nome varchar(40) not null,
	primary key(pdt_id),
	foreign key(pdt_id_vendedor) references trb.usuario(user_id),
	foreign key(pdt_id_categoria) references trb.categoria(ctg_id)
);
drop table trb.produto;
select * from trb.produto;
insert into trb.produto(pdt_id_vendedor, pdt_nome) values(7,'banana');
select * from trb.produto as pdt  cross join trb.usuario as usr where pdt.pdt_id = 1;
#############################################INICIO TABELA CATEGORIA###############################################################
create table trb.categoria(
	ctg_id serial not null unique,
	ctg_id_produto integer not null,
	ctg_id_usuario integer not null,
	ctg_nome varchar(20) not null,
	primary key (ctg_id),
	foreign key(ctg_id_usuario) references trb.usuario(user_id)
);
select * from trb.categoria;
drop table trb.categoria;
select * from trb.categoria as cat cross join trb.produto as pdt where cat.ctg_id_produto = pdt.pdt_id;
insert into trb.categoria(ctg_id_produto, ctg_id_usuario,ctg_nome) values(1,7,'fruta');
select * from trb.categoria as cat  cross join trb.usuario  as usr,trb.produto as pdt where pdt.pdt_id = cat.ctg_id;
select * from trb.categoria as cat  cross join trb.usuario  as usr , trb.produto as pdt where pdt.pdt_id = cat.ctg_id_produto;
--###################################################FIM TABELA CATEGORIA############################################################################

--###################################################INICIO TABELA LEILÂO#############################################################################
create or replace function data_inicio()
returns trigger as $$
declare 
	begin 
		if (new.ll_data_inicio < now()) then
				   raise exception 'data invalida';
		   return null;
		end if;

		if (new.ll_data_termino <= new.ll_data_inicio)then
				   raise exception 'data invalida';
		   return null;
		else
			return new;
		end if;
	end;
$$ Language 'plpgsql';

create trigger valida_data before insert
	on trb.leilao for each row 
	execute procedure data_inicio();
	
drop function data_inicio() cascade;	
drop trigger valida_data on trb.usuario;
	
create table trb.leilao(
	ll_id serial primary key,
	ll_id_vendedor integer not null,
	ll_id_produto integer not null,
	ll_valor_inicial real not null,
	ll_status varchar(10) not null,
	ll_data_inicio date not null,
	ll_data_termino date not null,
	foreign key(ll_id_vendedor) references trb.usuario(user_id),
	foreign key(ll_id_produto) references trb.produto(pdt_id)
);

drop table trb.leilao;
truncate table trb.leilao;
insert into trb.leilao(ll_id_vendedor, ll_id_produto, ll_valor_inicial,ll_status, ll_data_inicio,ll_data_termino) values(7,1,34.5,'ativo','2016-08-19','2016-08-20');
select * from trb.leilao;
select * from trb.leilao as ll cross join trb.produto as pdt, trb.usuario as usr, trb.categoria where ll.ll_id_vendedor = usr.user_id and pdt.pdt_id = 1;
--#################################################################FIM TABELA LEILÂO#######################################################################################

--#################################################################INICIO TABELA LANCE#######################################################################################
create or replace function  valor_lance()
returns trigger as $$
declare
valor_inicial real;
	begin 
		select ll_valor_inicial into valor_inicial from trb.leilao;
		--Verifica se o leilão dado não é menor que o valor inicial
		if (valor_inicial > new.lc_valor_lance) then
			raise exception 'valor invalido';
			return null;
		end if;
		return new;
	end;
$$ Language 'plpgsql';

create trigger valida_lance before insert
	on trb.lance for each row 
	execute procedure valor_lance();
insert into trb.lance(lc_id_comprador, lc_id_leilao, lc_valor_lance, lc_data_lance) values(6,4,20.0,now());	
drop function valor_lance() cascade;	
drop trigger valida_data on trb.usuario;

create table trb.lance(
	lc_id  serial unique not null,
	lc_id_comprador integer not null,
	lc_id_leilao integer not null,
	lc_valor_lance float not null,
	lc_data_lance date not null,
	primary key (lc_id),
	foreign key(lc_id_comprador) references trb.usuario(user_id),
	foreign key(lc_id_leilao) references trb.leilao(ll_id)
);
drop table trb.lance;
select (ll_valor_inicial) from trb.leilao;
SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';
select * from trb.lance;
truncate table trb.lance;
insert into trb.lance(lc_id_comprador, lc_id_leilao, lc_valor_lance, lc_data_lance) values(6,4,50.0,now());
select * from trb.lance as lc cross join trb.comprador as comp, trb.usuario as usr, trb.leilao as ll, trb.produto as pdt where lc_id_leilao = ll.ll_id and usr.user_id = lc.lc_id_comprador
and pdt.pdt_id = ll_id_produto;
--###################################################################NEGOCIO REALIZADO########################################################################
create table trb.negocio_realizado(
	nr_id serial unique not null,
	nr_id_produto integer not null,
	nr_id_comprador integer not null,
	nr_id_vendedor integer not null,
	nr_id_leilao integer not null,
	nr_data_realizado date,
	primary key (nr_id),
	foreign key (nr_id_produto) references trb.usuario(user_id),
	foreign key (nr_id_comprador) references trb.usuario(user_id),
	foreign key (nr_id_vendedor) references trb.usuario(user_id)
);
--###################################################################FIM NEGOCIO REALIZADO#####################################################################

--###################################################################INICIO TABELA COMENTARIO##################################################################
create table trb.comentario(
	com_id serial unique,
	com_id_usuario integer not null,
	com_id_leilao integer not null,
	com_texto text not null,
	primary key (com_id),
	foreign key(com_id_usuario) references trb.usuario(user_id),
	foreign key(com_id_leilao) references trb.leilao(ll_id)
);
drop table comentario;
insert into trb.comentario(com_id_usuario,com_id_leilao,com_texto) values(2,1,'esse produto presta?');
insert into trb.comentario(com_id_usuario,com_id_leilao,com_texto) values(1,1,'Claro!, qualidade garantida');
select * from trb.comentario as com cross join trb.usuario as usr where com.com_id_usuario = usr.user_id;
select * from trb.comentario;	
--######################################################FIM TABELA COMENTÁRIO######################################################
SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';

