#python script to interpret arm commands and turn them into machine code for my compiler
import sys
def decode_condition(two_characters):
    switcher = {
        '' : 0,
        'EQ' : 1,
        "GE" : 2,
        "LT" : 3,
    }
    return switcher.get(two_characters,"nothing")

def decode_opcode(three_characters):
    switcher = {
        "ADD" : 0,
        "SUB" : 1,
        "MUL" : 2,
        "ORR" : 3,
        "AND" : 4,
        "EOR" : 5,
        "MOV" : 6,
        "LSR" : 8,
        "LSL" : 9,
        "ROR" : 10,
        "CMP" : 11,
        "ADR" : 12,
        "LDR" : 13,
        "STR" : 14,
        "NOP" : 15,
    }
    return switcher.get(three_characters,"nothing")

def rshift(val,n): return (val>>n) & (0x7fffffff>>(n-1))

def alu(op1,op2,opcode,immediate,condition,cin,vin,zin,nin):
    res = dict();
    result = None
    if(opcode == 0):
        result = op1+op2;
        if((rshift(result,31)) !=  (rshift(result,15))):
           v = 1
        else:
           v = 0
        if(result > 65536):
            c = 1
        else:
            c = 0
    if(opcode == 1):
        result = op1-op2;
        if((rshift(result,31)) !=  (rshift(result,15))):
           v = 1
        else:
           v = 0
        if((result >= 65536)):
           c = 0
        else:
           c = 1
    if(opcode == 2):
        result = op1*op2
    if(opcode == 3):
        result = op1|op2
    if(opcode == 4):
        result = op1&op2
    if(opcode == 5):
        result = op1^op2
    if(opcode == 6):
        result = immediate
    if(opcode == 7):
        result = op1
    if(opcode == 8):
        print("immediate: "+str(immediate & 0xF))
        print("op1: " + str(op1))
        result = rshift(op1,immediate & 0xF)
        print("result" + str(result))
    if(opcode == 9):
        result = op1 << (immediate & 0xF)
    if(opcode == 10):
        result = (op1 << (16 - (immediate & 0xF))) | (rshift(op1,immediate & 0xF))
    if(opcode == 11):
        result = op1-op2;
        print("result" + str(result))
        if((rshift(result,31)) !=  (rshift(result,15))):
           v = 1
        else:
           v = 0
        if((result >= 65536)):
           c = 1
        else:
           c = 0
        result = None
    if(opcode == 12):
        result = immediate
    if(opcode == 13):
        result = None
    if(opcode == 14):
        result = None
    if(opcode == 15):
        result = None
    print(result)
    print(opcode)
    if((opcode == 1) or (opcode == 0) or (opcode == 11)):
        if(result >= 0):
            res['n'] = 0
        else:
            res['n'] = 1
        if(result == 0):
            res['z'] = 1
        else:
            res['z'] = 0
        if(opcode != 2):
            res['v'] = v
            res['c'] = c
    if((condition == 0) or ((condition == 1) and (zin == 1)) or ((condition == 2) and (nin == vin)) or ((condition == 3) and (nin != vin))):
        print("CONDITION: "+str(condition))
        print("ZIN: "+str(zin))
        res['cond_succ']= 1
    else:
        res['cond_succ'] = 0
    res['res'] = result
    return res

text_file = sys.argv[1]
print(text_file)
reg = [None] * 8
mem = [None] * 127
with open(text_file) as f:
    wr = open('data.txt', "w")
    line_number = 0
    din = ""
    c=0
    v=0
    z=0
    n=0
    #for line in range(1,127):
    for line in f:
        alu_result = 0
        #print (line)
        din=""
        if (line[0] == "/"):
            continue
        line_number = line_number + 1
        decode_line= line.split(',')
        #zero data
        condition = 0
        opcode = 0
        condition = 0
        operand_1 =0 
        operand_2=0
        destination_reg=0
        immediate_operand=0
        #
        #print(decode_line)
        if(len(decode_line) > 4): #this means there is a shift or rotate
            opcode = decode_opcode(decode_line[3][0:3])
            opcode_string = decode_line[3][0:3]
        else:
            opcode = decode_opcode(decode_line[0][0:3])
            opcode_string = decode_line[0][0:3]
        if(len(decode_line[0]) > 3):
            condition = decode_condition(decode_line[0][3:5])
        else:
            condition = 0
        #
        #
        #
        if(opcode_string == "LDR" or opcode_string == "STR" or opcode_string == "ADR"): #it is a load or store
            destination_reg = decode_line[1][1]
            if(decode_line[2][0] == "R"):
                operand_1 = decode_line[2][1]
                immediate_operand = 0
            else:
                immediate_operand = decode_line[2]
                operand_1 = 0
            operand_2 = 0
            #
            condition = format(int(condition), '02b')
            opcode = format(opcode,'04b')
            operand_1 = format(int(operand_1),'03b')
            destination_reg = format(int(destination_reg), '03b')
            operand_2 = format(int(operand_2),'03b')
            immediate_operand = format(int(immediate_operand),'07b')
            #
            din =str(condition)
            din+=str(opcode)
            din+=str(destination_reg)
            if(opcode_string == "LDR"):
                din+=str(operand_1)
                din+=str(operand_2)
                din+=(str(0)) #extra bit
            elif(opcode_string == "STR"):
                din+=str(destination_reg)
                din+=str(operand_1)
                din+="0"
            else:
                din+=str(immediate_operand)
        elif(opcode_string == "MOV" or opcode_string == "CMP"):
            destination_reg = decode_line[1][1]
            if(decode_line[2][0] == "R"):
                operand_1 = decode_line[2][1]
                immediate_operand = "0"
                if(opcode_string == "MOV"):
                    opcode = opcode + 1
            else:
                immediate_operand = decode_line[2]
                operand_1 = 0
            condition = format(int(condition), '02b')
            opcode = format(opcode,'04b')
            operand_1 = format(int(operand_1),'03b')
            destination_reg = format(int(destination_reg), '03b')
            operand_2 = format(int(operand_2),'03b')
            immediate_operand = format(int(immediate_operand),'07b')
            din =str(condition)
            din+=str(opcode)
            if(opcode_string == "CMP"): #11 is compare and not move :)
                din+="000" #for compare the first reg we found was actually the operand 1
                din+=str(destination_reg) #for compare operand1 was really operand2
                din+=str(operand_1)
                din+=(str(0)) #extra bit
            elif(decode_line[2][0] == "R"):
                din += str(destination_reg)
                din += str(operand_1)
                din += "000"
                din += "0"
            else:
                din+=str(destination_reg)
                din+=str(immediate_operand)
        elif(opcode_string == "LSR" or opcode_string == "LSL" or opcode_string == "ROR"): #s
            destination_reg = decode_line[1][1]
            operand_1 = decode_line[2][1]
            immediate_operand = decode_line[4]
            condition = format(int(condition), '02b')
            opcode = format(opcode,'04b')
            operand_1 = format(int(operand_1),'03b')
            operand_2 = format(int(operand_2),'03b')
            destination_reg = format(int(destination_reg), '03b')
            immediate_operand = format(int(immediate_operand),'04b')
            din =str(condition)
            din+=str(opcode)
            din+=str(destination_reg)
            din+=str(operand_1)
            din+=str(immediate_operand)
        elif(opcode_string == "NOP"):
            din = ""
            opcode = format(opcode,'04b')
            din ="00" #cond
            din+=str(opcode)#opcode
            din+="000" #des
            din+="000" #op1
            din+="000" #op2
            din+="0"   #1
        else: #normal add, sub ect
            immediate_operand = 0
            destination_reg = decode_line[1][1]
            operand_1 = decode_line[2][1]
            operand_2 = decode_line[3][1]
            condition = format(int(condition), '02b')
            opcode = format(opcode,'04b')
            operand_1 = format(int(operand_1),'03b')
            operand_2 = format(int(operand_2),'03b')
            destination_reg = format(int(destination_reg), '03b')
            immediate_operand = format(int(immediate_operand),'04b')
            din =str(condition)
            din+=str(opcode)
            din+=str(destination_reg)
            din+=str(operand_1)
            din+=str(operand_2)
            din+=(str(0)) #extra bit
        wr.write(hex(int(din,2))[2:]+"\n")

#print(mem)
wr.close()
