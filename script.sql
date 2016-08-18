create database trabalho_bd;
create schema trb;
drop database trabalho_bd;
--####################################################TABELA USUARIO#######################################################
--#validação de tabela usuario
create or replace function valida_cpf()
returns trigger as $$
	begin 
		if (length(new.user_cpf) < 11) then
				   raise exception 'não pode ser menor que 11';
		   return null;
		end if;
		
		-- Se conter 11 caracteres insere
		if ((length(new.user_cpf) = 11)) then
			return new;
		end if;
	end;
$$ Language 'plpgsql';
create trigger valida_cpf before insert
	on trb.usuario for each row 
	execute procedure valida_cpf();
	
drop function valida_cpf() cascade;	
drop trigger valida_cpf on trb.usuario;
insert into trb.usuario(user_nome, user_email, user_senha, user_cpf) values('jose','aline@gmail.com', '123','12345678916');

create table trb.usuario(
	user_id serial,
	user_nome varchar(40) not null,
	user_email varchar(40) not null,
	user_senha varchar(40) not null,
	user_cpf varchar(11) not null,
	primary key (user_id)
);
alter table trb.usuario add user_cpf varchar(11);
select * from trb.usuario;	
drop table trb.usuario;
delete from trb.usuario where user_id >= 4;
insert into trb.usuario(user_nome, user_email, user_senha) values('david','davidturati@gmail.com', '123');
insert into trb.usuario(user_nome, user_email, user_senha) values('liliane','lili@gmail.com', '123');
insert into trb.usuario(user_nome, user_email, user_senha, user_cpf) values('marta','marta@gmail.com', '123','12345678919');
--################################################FIM TABELA USUARIO#########################################################

--################################################ TABELA telefone#########################################################
create or replace function valida_telefone()
returns trigger as $$
declare 
fixo varchar := new.tel_fixo;
cel varchar  := new.tel_celular;
	begin 
	
		if(length(fixo) != 8) then
			raise 'tamanho incorreto';
			return null;
		end if;

		if(length(cel) != 8) then
			raise 'tamanho incorreto';
			return null;
		end if;

		if(new.tel_id is null) then
			raise 'não pode ser nulo';
			return null;
		end if;

		return new;
		
	end;
$$ Language 'plpgsql';
create trigger valida_telefone before insert
	on trb.telefone for each row 
	execute procedure valida_telefone();
drop function valida_telefone() cascade;	
drop trigger valida_telefone on trb.telefone;
insert into trb.telefone(tel_id, tel_fixo,tel_celular) values(1,'99972826','99972827');	
create table trb.telefone(
	tel_id integer not null unique,
	tel_fixo integer,
	tel_celular integer not null,
	primary key (tel_id),
	foreign key (tel_id) references trb.usuario(user_id)
);
select * from trb.telefone;
drop table trb.telefone;
truncate table trb.telefone;
insert into trb.telefone(tel_id,tel_fixo,tel_celular) values(1,99972826,99972826);
insert into trb.telefone(tel_id,tel_fixo,tel_celular) values(2,'999729','9972827');
insert into trb.telefone(tel_id,tel_fixo,tel_celular) values(2,'99972826','99972827');
--####################################################FIM TABELA TELEFONE#######################################################
create table trb.endereco(
	end_id integer not null unique,
        end_id_user integer not null,
        end_rua varchar(100) not null,
        end_numero varchar(10) not null,
        end_bairro varchar(40) not null,
        end_cep varchar(45) not null,
        end_complemento varchar(45) not null,
        end_referencia varchar(45) not null,
    
        foreign key (end_id_user) references trb.usuario(user_id)
);
drop table trb.endereco;
###########################################################################################################
create table trb.cidade(
	cd_id integer not null unique primary key,
	cd_id_endereco integer not null,
	cd_nome varchar(45) not null,
	foreign key (cd_id_endereco) references  trb.endereco(end_id)
);
############################################################################################################
create table trb.estado(
	es_id integer primary key not null unique,
	es_id_cidade integer not null,
	es_nome varchar(45) not null,
	foreign key (es_id_cidade) references trb.cidade(cd_id)
);
select * from trb.estado;
############################################################################################################
create table trb.pais(
	ps_id integer primary key unique not null,
	ps_id_estado integer not null,
	ps_nome varchar(45) not null,
	foreign key (ps_id_estado) references trb.estado(es_id)
);
############################################################################################################
create table trb.comprador(
	cp_id serial primary key not null,
	cp_id_usuario integer not null,
	foreign key(cp_id_usuario) references trb.usuario(user_id)
);
drop table trb.comprador;
select * from trb.comprador;
delete  from trb.comprador as comp where comp.cp_id = 1;
insert into trb.comprador(cp_id_usuario) values(1);
select * from trb.comprador as comp cross join trb.usuario as usr where comp.cp_id_usuario = usr.user_id;
insert into trb.comprador(cp_id_usuario) values(2);
############################################################################################################
create table trb.vendedor(
	vd_id serial not null primary key,
	vd_id_usuario integer not null,
	foreign key(vd_id_usuario) references trb.usuario(user_id)
);
insert into trb.vendedor(vd_id_usuario) values(1);
select * from trb.vendedor as ven cross join trb.usuario as usr where ven.vd_id_usuario = usr.user_id;
############################################################################################################
create table trb.produto(
	pdt_id serial not null primary key,
	pdt_id_vendedor integer not null,
	pdt_nome varchar(40) not null,
	foreign key(pdt_id_vendedor) references trb.usuario(user_id)
);
drop table trb.produto;
select * from trb.produto;
insert into trb.produto(pdt_id_vendedor, pdt_nome) values(1,'banana');
select * from trb.produto as pdt  cross join trb.usuario as usr where pdt.pdt_id = 1;
############################################################################################################
create table trb.categoria(
	ctg_id serial primary key,
	ctg_id_produto integer not null,
	ctg_id_usuario integer not null,
	ctg_nome varchar(40) not null,
	foreign key(ctg_id_produto) references trb.produto(pdt_id),
	foreign key(ctg_id_usuario) references trb.usuario(user_id)
);
select * from trb.categoria;
select * from trb.categoria as cat cross join trb.produto as pdt where cat.ctg_id_produto = pdt.pdt_id;
insert into trb.categoria(ctg_id_produto, ctg_id_usuario,ctg_nome) values(2,1,'fruta');
select * from trb.categoria as cat  cross join trb.usuario  as usr,trb.produto as pdt where pdt.pdt_id = cat.ctg_id;
select * from trb.categoria as cat  cross join trb.usuario  as usr , trb.produto as pdt where pdt.pdt_id = cat.ctg_id_produto;
############################################################################################################
create table trb.leilao(
	ll_id serial primary key,
	ll_id_vendedor integer not null,
	ll_id_produto integer not null,
	ll_valor_inicial real not null,
	ll_status varchar(10) not null,
	ll_data_inicio date,
	ll_data_termino date,
	foreign key(ll_id_vendedor) references trb.usuario(user_id),
	foreign key(ll_id_produto) references trb.produto(pdt_id)
);
drop table trb.leilao;
insert into trb.leilao(ll_id_vendedor, ll_id_produto, ll_valor_inicial,ll_status) values(1,1,34.5,'ativo');
select * from trb.leilao;
select * from trb.leilao as ll cross join trb.produto as pdt, trb.usuario as usr, trb.categoria where ll.ll_id_vendedor = usr.user_id and pdt.pdt_id = 1;
########################################################################################################################################################
create table trb.lance(
	lc_id  serial primary key,
	lc_id_comprador integer not null,
	lc_id_leilao integer not null,
	lc_valor_lance float not null,
	lc_data_lance date not null,
	foreign key(lc_id_comprador) references trb.usuario(user_id),
	foreign key(lc_id_leilao) references trb.leilao(ll_id)
);
SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';

select * from trb.lance;
insert into trb.lance(lc_id_comprador,lc_id_leilao,lc_valor_lance) values(2,1,45.0);
select * from trb.lance as lc cross join trb.comprador as comp, trb.usuario as usr, trb.leilao as ll, trb.produto as pdt where lc_id_leilao = ll.ll_id and usr.user_id = lc.lc_id_comprador
and pdt.pdt_id = ll_id_produto;
############################################################################################################
create table trb.comentario(
	com_id serial primary key,
	com_id_usuario integer not null,
	com_id_leilao integer not null,
	com_texto text not null,
	foreign key(com_id_usuario) references trb.usuario(user_id),
	foreign key(com_id_leilao) references trb.leilao(ll_id)
);
drop table comentario;
insert into trb.comentario(com_id_usuario,com_id_leilao,com_texto) values(2,1,'esse produto presta?');
insert into trb.comentario(com_id_usuario,com_id_leilao,com_texto) values(1,1,'Claro!, qualidade garantida');
select * from trb.comentario as com cross join trb.usuario as usr where com.com_id_usuario = usr.user_id;
select * from trb.comentario;	
############################################################################################################
SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';

