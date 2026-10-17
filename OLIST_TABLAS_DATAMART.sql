

create table dim_producto (
    id_producto int primary key identity(1,1),
    product_id nvarchar(50),
    categoria_original nvarchar(100),
    categoria_ingles nvarchar(100),
    peso_g int,
    largo_cm int,
    alto_cm int,
    ancho_cm int
);

create table dim_cliente (
    id_cliente int primary key identity(1,1),
    customer_id nvarchar(50),
    customer_unique_id nvarchar(50),
    codigo_postal int,
    ciudad nvarchar(100),
    estado char(2)
);

create table dim_vendedor (
    id_vendedor int primary key identity(1,1),
    seller_id nvarchar(50),
    codigo_postal int,
    ciudad nvarchar(100),
    estado char(2)
);

create table dim_tiempo (
    id_tiempo int primary key,
    fecha date,
    dia int,
    mes int,
    trimestre int,
    anio int
);

create table dim_estado_pedido (
    id_estado int primary key identity(1,1),
    estado_pedido nvarchar(30)
);


create table fact_ventas (
    id_hecho int primary key identity(1,1),
    id_pedido nvarchar(50) not null,
    numero_item int not null,
    id_producto int not null,
    id_vendedor int not null,
    id_cliente int not null,
    id_tiempo int not null,
    id_estado int not null,
    precio decimal(12,2) not null,
    flete decimal(12,2) not null,
    cantidad_articulos int not null,

    foreign key (id_producto)
        references dim_producto(id_producto),

    foreign key (id_vendedor)
        references dim_vendedor(id_vendedor),

    foreign key (id_cliente)
        references dim_cliente(id_cliente),

    foreign key (id_tiempo)
        references dim_tiempo(id_tiempo),

    foreign key (id_estado)
        references dim_estado_pedido(id_estado)
);
----------------------------------

select
    row_number() over (order by newid()) as numero,
    n.nombre,
    a.apellido as apellido1,
    b.apellido as apellido2
into #combinaciones
from (values
    ('Ana'), ('Maria'), ('Joao'), ('Lucas'), ('Julia'),
    ('Pedro'), ('Beatriz'), ('Gabriel'), ('Laura'), ('Rafael'),
    ('Mariana'), ('Bruno'), ('Camila'), ('Felipe'), ('Larissa'),
    ('Matheus'), ('Isabela'), ('Thiago'), ('Amanda'), ('Gustavo'),
    ('Leticia'), ('Daniel'), ('Fernanda'), ('Rodrigo'), ('Carolina'),
    ('Eduardo'), ('Bianca'), ('Leonardo'), ('Patricia'), ('Vinicius'),
    ('Marcos'), ('Renata'), ('Andre'), ('Claudia'), ('Diego'),
    ('Sofia'), ('Henrique'), ('Natalia'), ('Caio'), ('Luiza'),
    ('Ricardo'), ('Vanessa'), ('Alexandre'), ('Tatiane'), ('Fabio'),
    ('Priscila'), ('Roberto'), ('Aline'), ('Samuel'), ('Isadora')
) n(nombre)
cross join (values
    ('Silva'), ('Santos'), ('Oliveira'), ('Souza'), ('Pereira'),
    ('Costa'), ('Rodrigues'), ('Almeida'), ('Nascimento'), ('Lima'),
    ('Araujo'), ('Fernandes'), ('Carvalho'), ('Gomes'), ('Martins'),
    ('Rocha'), ('Ribeiro'), ('Alves'), ('Monteiro'), ('Mendes'),
    ('Barbosa'), ('Cardoso'), ('Correia'), ('Dias'), ('Castro'),
    ('Teixeira'), ('Moreira'), ('Nunes'), ('Marques'), ('Machado'),
    ('Freitas'), ('Batista'), ('Moura'), ('Campos'), ('Ramos'),
    ('Cavalcanti'), ('Azevedo'), ('Pinto'), ('Lopes'), ('Miranda'),
    ('Barros'), ('Melo'), ('Farias'), ('Reis'), ('Duarte'),
    ('Tavares'), ('Cunha'), ('Peixoto'), ('Rezende'), ('Borges')
) a(apellido)
cross join (values
    ('Silva'), ('Santos'), ('Oliveira'), ('Souza'), ('Pereira'),
    ('Costa'), ('Rodrigues'), ('Almeida'), ('Nascimento'), ('Lima'),
    ('Araujo'), ('Fernandes'), ('Carvalho'), ('Gomes'), ('Martins'),
    ('Rocha'), ('Ribeiro'), ('Alves'), ('Monteiro'), ('Mendes'),
    ('Barbosa'), ('Cardoso'), ('Correia'), ('Dias'), ('Castro'),
    ('Teixeira'), ('Moreira'), ('Nunes'), ('Marques'), ('Machado'),
    ('Freitas'), ('Batista'), ('Moura'), ('Campos'), ('Ramos'),
    ('Cavalcanti'), ('Azevedo'), ('Pinto'), ('Lopes'), ('Miranda'),
    ('Barros'), ('Melo'), ('Farias'), ('Reis'), ('Duarte'),
    ('Tavares'), ('Cunha'), ('Peixoto'), ('Rezende'), ('Borges')
) b(apellido);

-- asignar nombres a todos los clientes
with lista_clientes as (
    select
        customer_id,
        row_number() over (order by newid()) as numero
    from dbo.dim_cliente
)
update d
set nombre_cliente =
    c.nombre + ' ' + c.apellido1 + ' ' + c.apellido2
from dbo.dim_cliente d
join lista_clientes l
    on d.customer_id = l.customer_id
join #combinaciones c
    on c.numero = l.numero;

-- asignar nombres a todos los vendedores
with lista_vendedores as (
    select
        seller_id,
        row_number() over (order by newid()) as numero
    from dbo.dim_vendedor
)
update d
set nombre_vendedor =
    c.nombre + ' ' + c.apellido1 + ' ' + c.apellido2
from dbo.dim_vendedor d
join lista_vendedores l
    on d.seller_id = l.seller_id
join #combinaciones c
    on c.numero = l.numero;

drop table #combinaciones;
go

