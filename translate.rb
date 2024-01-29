class Word
    def initialize(word, pos, translations)
        @word = word
        @pos = pos
        @translations = translations
    end

    def getWord()
        @word
    end

    def getPos()
        @pos
    end

    def getTranslation(language)
        @translations[language]
    end

    def getTranslations()
        @translations
    end

    def addTranslation(language, word)
        @translations.store(language, word)
    end
end

class Translator
    def initialize(words_file, grammar_file)
        @words = Hash.new()
        @grammar = Hash.new()
        langHolder = Array.new()
        translHolder = Array.new()
        f = File.open(words_file)
        line = f.gets
        while line
            if line =~ /([a-z\-]+), ([A-Z]{3}), ([A-Z][a-z\d]*:[a-z\-]+)/
                word = $1
                pos = $2
                langHolder = line.scan(/([A-Z][a-z\d]*):/)
                translHolder = line.scan(/:([a-z\-]+)/)
                translations = Hash.new()
                if langHolder.length == translHolder.length
                    langHolder.each_with_index do |i, n|
                        translations.store(i.join, translHolder[n].join)
                    end
                    translations.store("English", word)

                    if (@words.key?(pos) == false)
                        @words.store(pos, Array.new())
                    end 

                    @words[pos].push(Word.new(word, pos, translations))
                end
            end
            line = f.gets
        end

        grammarHolder = Array.new()
        f = File.open(grammar_file)
        line = f.gets
        while line
            if line =~ /([A-Z][a-z\d]+): ([A-Z]{3})/
                lang = $1
                @grammar.store(lang, Array.new())
                grammarHolder = line.scan(/([A-Z]{3}[{]\d[}]|[A-Z]{3})/)
                grammarHolder.each do |x|
                    if "#{x}" =~ /([A-Z]{3})[{](\d)[}]/
                        pos = $1
                        num = $2.to_i
                        while num > 0
                            @grammar[lang] << pos
                            num = num - 1
                        end
                    else
                        if "#{x}" =~ /([A-Z]{3})/
                            @grammar[lang] << $1
                        end
                    end
                end
            end
            line = f.gets
        end
        
    end

    # part 1
  
    def updateLexicon(inputfile)
        wordExists = false
        f = File.open(inputfile)
        line = f.gets
        while line
            if line =~ /([a-z\-]+), ([A-Z]{3}), ([A-Z][a-z\d]*:[a-z\-]+)/
                word = $1
                pos = $2
                langHolder = line.scan(/([A-Z][a-z\d]*):/)
                translHolder = line.scan(/:([a-z\-]+)/)
                translations = Hash.new()
                if langHolder.length == translHolder.length
                    langHolder.each_with_index do |i, n|
                        translations.store(i.join, translHolder[n].join)
                    end
                end
                translations.store("English", word)

                if (@words.key?(pos) == false)
                    @words.store(pos, Array.new())
                    @words[pos].push(Word.new(word, pos, translations))
                else 
                    @words[pos].each do |x|
                        if x.getWord == word
                            wordsExist = true
                            translations.each do |k, v|
                                if x.getTranslation(k).nil?
                                    x.addTranslation(k, v)
                                end
                            end
                        end
                    end
                    if (wordExists == false)
                        @words[pos].push(Word.new(word, pos, translations))
                    end
                end
                
            end
            wordExists = false
            line = f.gets
        end
    end
  
    def updateGrammar(inputfile)
        grammarHolder = Array.new()
        f = File.open(inputfile)
        line = f.gets
        while line
            if line =~ /([A-Z][a-z\d]+): ([A-Z]{3})/
                lang = $1
                if @grammar.key?(lang)
                    @grammar[lang].clear
                else 
                    @grammar.store(lang, Array.new())
                end
                grammarHolder = line.scan(/([A-Z]{3}[{]\d[}]|[A-Z]{3})/)
                grammarHolder.each do |x|
                    if "#{x}" =~ /([A-Z]{3})[{](\d)[}]/
                        pos = $1
                        num = $2.to_i
                        while num > 0
                            @grammar[lang] << pos
                            num = num - 1
                        end
                    else
                        if "#{x}" =~ /([A-Z]{3})/
                            @grammar[lang] << $1
                        end
                    end
                end
            end
            line = f.gets
        end
    end

    # part 2
  
    def generateSentence(language, struct)
        wordExists = false
        result = String.new()
        if (struct.instance_of? String)
            if @grammar.key?(struct)
                struct = Array.new(@grammar[struct])
            else
                return nil
            end
        end 
        
        struct.each_with_index do |pos, i|
            if @words.key?(pos)
                @words[pos].each do |w|
                    if w.getTranslation(language).nil? == false
                        result.concat(w.getTranslation(language))
                        wordExists = true
                        break
                    end
                end
                if wordExists == false
                    return nil
                end
            else 
                return nil
            end
            if (i != struct.length - 1)
                result.concat(" ")
            end
            wordExists = false
        end
        return result
    end
  
    def checkGrammar(sentence, language)
        checker = false
        holder = sentence.split(" ")
        if (@grammar.key?(language))
            struct = Array.new(@grammar[language])
        end

        struct.each_with_index do |pos, i|
            if (@words.key?(pos))
                @words[pos].each do|w|
                    if (w.getTranslation(language) == holder[i])
                        checker = true
                    end
                end
                if (checker == false)
                    return false
                end
                checker = false
            else
                return false
            end
        end

        return true
    end
  
    def changeGrammar(sentence, struct1, struct2)
        puts sentence
        holder = sentence.split(" ")
        match = Hash.new()
        result = Array.new()
        if (struct1.instance_of?(String))
            s1 = Array.new(@grammar[struct1])
        else
            s1 = Array.new(struct1)
        end
        if (struct2.instance_of?(String))
            s2 = Array.new(@grammar[struct2])
        else
            s2 = Array.new(struct2)
        end
        s2.each do |pos|
            i = s1.find_index(pos)
            if i.nil?
                return nil
            end
            result.append(holder[i])
            s1[i] = "c"
        end

        return result.join(" ")
    end

    # part 3
  
    def changeLanguage(sentence, language1, language2)
        holder = sentence.split(" ")
        result = Array.new()
        checker = false
        if (@grammar.key?(language1))
            struct1 = Array.new(@grammar[language1])
        end

        if (language1 == "English")
            struct1.each_with_index do |pos, i| 
                @words[pos].each do |w|
                    if w.getWord == holder[i] && w.getTranslation(language2).nil? == false
                        result.append(w.getTranslation(language2))
                        checker = true
                    end
                end
                if checker == false
                    return nil
                end
                checker = false
            end
        else
            struct1.each_with_index do |pos, i|
                @words[pos].each do |w|
                    if w.getTranslation(language1) == holder[i] && w.getTranslation(language2).nil? == false
                        result.append(w.getTranslation(language2))
                        checker = true
                    end
                end
                if checker == false
                    return nil
                end
                checker = false
            end
        end

        return result.join(" ")
    end
  
    def translate(sentence, language1, language2)
        holder = self.changeLanguage(sentence, language1, language2)
        if holder.nil?
            return nil
        end
        result = self.changeGrammar(holder, language1, language2)
        return result
    end
end  
