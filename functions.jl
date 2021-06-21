using PrettyTables

function lerVertices(vertices, dados)

    countVertices = 1
    for i = 1:length(dados["vertices"])
        
        nome = dados["vertices"][i]["nome"]
        aux = Vertice(countVertices, nome, Array{Aresta, 1}())
        push!(vertices, aux)
        countVertices += 1
        
    end

end

function LerDirecionadas(arestas, vertices, dados, contador)

    try
        if (length(dados["arestasDirecionadas"]) <= 0)
            return contador
        end
    catch
        @warn "Key \"arestasDirecionadas\" not found"
        return contador
    end
    
    for i = 1:length(dados["arestasDirecionadas"])

        nome = dados["arestasDirecionadas"][i]["nome"]
        origem = dados["arestasDirecionadas"][i]["origem"]
        destino = dados["arestasDirecionadas"][i]["destino"]
        peso = dados["arestasDirecionadas"][i]["peso"]
        
        # Procurando os vertices correspondentes
        ori = -1
        dest = -1
        for j = 1:length(vertices)
            if (origem == vertices[j].nome)
                ori = vertices[j].id
            end
            
            if (destino == vertices[j].nome)
                dest = vertices[j].id
            end
            
            if (ori != -1 && dest != -1)
                break
            end
        end

        # Criando arestas
        aux = Direcionada(contador, nome, ori, dest, peso, false)
        push!(arestas, aux)
        contador += 1

    end

    return contador

end

function lerNaoDirecionadas(arestas, vertices, dados, contador)
    try
        if (length(dados["arestasNaoDirecionadas"]) <= 0)
            return contador
        end
    catch
        @warn "Key \"arestasNaoDirecionadas\" not found"
        return contador
    end
    
    for i = 1:length(dados["arestasNaoDirecionadas"])

        nome = dados["arestasNaoDirecionadas"][i]["nome"]
        vertice1 = dados["arestasNaoDirecionadas"][i]["vertice1"]
        vertice2 = dados["arestasNaoDirecionadas"][i]["vertice2"]
        peso = dados["arestasNaoDirecionadas"][i]["peso"]

        # Procurando os vertices correspondentes
        v1 = -1
        v2 = -1
        for j = 1:length(vertices)
            if (vertice1 == vertices[j].nome)
                v1 = vertices[j].id
            end

            if (vertice2 == vertices[j].nome)
                v2 = vertices[j].id
            end

            if (v1 != -1 && v2 != -1)
                break
            end
        end

        # Criando arestas
        aux = NaoDirecionada(contador, nome, v1, v2, peso, false)
        push!(arestas, aux)
        contador += 1

    end

    return contador
end

function relacionarVerticesArestas(vertices, arestas)
    for i = 1:length(arestas)
        if (typeof(arestas[i]) == typeof(NaoDirecionada()))
            v1 = arestas[i].vertice1
            v2 = arestas[i].vertice2

            push!(vertices[v1].arestas, arestas[i])
            push!(vertices[v2].arestas, arestas[i])
        end

        if (typeof(arestas[i]) == typeof(Direcionada()))
            origem = arestas[i].origem

            push!(vertices[origem].arestas, arestas[i])
        end
    end
end

function criarTabelaPesos(tabela, arestas)
    
    for i = 1:length(arestas)

        if (typeof(arestas[i]) == typeof(Direcionada))

            origem = arestas[i].origem
            destino = arestas[i].destino
            tabela[origem, destino] = arestas[i].peso

        elseif (typeof(arestas[i]) == typeof(NaoDirecionada))
            v1 = arestas[i].vertice1
            v2 = arestas[i].vertice2
            tabela[v1, v2] = arestas[i].peso
            tabela[v2, v1] = arestas[i].peso
        else
        end

    end

end

function encontrarVizinho(vertice::Vertice, aresta::Aresta)
    if (typeof(aresta) == typeof(Direcionada()))
        return aresta.destino
    else
        id = vertice.id

        if (id == aresta.vertice1)
            return aresta.vertice2
        else
            return aresta.vertice1
        end
    end
end

function encontrarVizinhos(vertice::Vertice)
    vizinhos = []

    for i = 1:length(vertice.arestas)

        if (typeof(vertice.arestas[i]) == typeof(Direcionada()))
            push!(vizinhos, vertice.arestas[i].destino)
        else
            id = vertice.id
    
            if (id == vertice.arestas[i].vertice1)
                push!(vizinhos, vertice.arestas[i].vertice2)
            else
                push!(vizinhos, vertice.arestas[i].vertice1)
            end
        end

    end

    return vizinhos
end

function imprimeResultado(vertices, dtTimeLine, rotTimeLine, verticeOrigem)

    local posOrigem = 0
    for i = 1:length(vertices)
        if (vertices[i].nome == verticeOrigem)
            posOrigem = i
            break
        end
    end

    local columns = length(vertices) + 1
    local rowsDT  = length(dtTimeLine)
    local rowsROT = length(rotTimeLine)

    local dataDT  = Array{Any, 2}(undef, rowsDT, columns)
    local dataROT = Array{Any, 2}(undef, rowsROT, columns)
    local header  = Array{Any, 1}(undef, columns)
    local alignments = [:l]

    header[1] = "DT"
    for i = 2:columns
        header[i] = vertices[i - 1].nome
        push!(alignments, :c)
    end

    for i = 1:rowsDT
        for j = 1:columns
            if (j == 1)
                dataDT[i, j] = "It $(i)"
            elseif (j - 1 == posOrigem)
                dataDT[i, j] = 0
            else
                if (dtTimeLine[i][j - 1] <= typemax(Int64) && dtTimeLine[i][j - 1] >= (typemax(Int64) - 15e6))
                    dataDT[i, j] = "inf"
                else
                    dataDT[i, j] = dtTimeLine[i][j - 1]
                end
            end
        end
    end
    pretty_table(dataDT; header = header, alignment = alignments)


    header[1] = "ROT"
    for i = 1:rowsROT
        for j = 1:columns
            if (j == 1)
                dataROT[i, j] = "It $(i)"
            elseif (j - 1 == posOrigem)
                dataROT[i, j] = verticeOrigem
            else
                if (rotTimeLine[i][j - 1] == 0)
                    dataROT[i, j] = 0
                else
                    dataROT[i, j] = vertices[rotTimeLine[i][j - 1]].nome
                end
            end
        end
    end
    pretty_table(dataROT; header = header, alignment = alignments)

end

function encontraFechoTransitivo(vertices)
    
    vet = []
    for i = 1:length(vertices)
        push!(vet, [])
    end

    for i = 1:length(vertices)

        for j = 1:length(vertices[i].arestas)

            if (typeof(vertices[i].arestas[j]) == typeof(Direcionada()))
                x = vertices[i].arestas[j].destino
                push!(vet[x], i)
            else
                id = vertices[i].id
                if (id == vertices[i].arestas[j].vertice1)
                    x = vertices[i].arestas[j].vertice2
                    push!(vet[x], i)
                else
                    x = vertices[i].arestas[j].vertice1
                    push!(vet[x], i)
                end
            end

        end

    end

    return vet

end

function loopDFS(vertice, vet, pos, vertices)
    
    vertice.visitado = true
    push!(vet[pos], vertice.id)
    for i = 1:length(vertice.arestas)
        vizinho = 0

        if (typeof(vertice.arestas[i]) == typeof(Direcionada()))
            vizinho = vertice.arestas[i].destino
        else
            id = vertice.id
            if (id == vertice.arestas[i].vertice1)
                vizinho = vertice.arestas[i].vertice2
            else
                vizinho = vertice.arestas[i].vertice1
            end
        end

        if (vertices[vizinho].visitado == false)
            vertice.arestas[i].visitado = true
            loopDFS(vertices[vizinho], vet, pos, vertices)
        else
            if (vertice.arestas[i].visitado == false)
                vertice.arestas[i].visitado = true
            end
        end

    end

end

function dfs(vertices, arestas)
    
    vet= []

    for i = 1:length(vertices)
        push!(vet, [])
        loopDFS(vertices[i], vet, i, vertices)

        for j = 1:length(vertices)
            vertices[j].visitado = false
        end
        for j = 1:length(arestas)
            arestas[j].visitado = false
        end
        # for i = 1:length(vertices)
        # end
    end

    for i = 1:length(vet)
        deleteat!(vet[i], 1)
    end


    return vet

end

function inverteDFS(vetDFS)

    retorno = []

    for i = 1:length(vetDFS)
        push!(retorno, [])
    end

    for i = 1:length(vetDFS)
        for j = 1:length(vetDFS[i])
            push!(retorno[vetDFS[i][j]], i)
        end
    end
    
end