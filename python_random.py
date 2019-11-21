import sys
import random


def rshift(val,n): return (val>>n) & (0x7fffffff>>(n-1))
def sign_bit(val): return (val < 0)
def bit15(val): return (rshift(val, 15) & 1)

def alu(op1,op2,opcode,immediate,condition,cin,vin,zin,nin):
    res = dict();
    result = None

    if(opcode == 0):
        result = op1+op2;
        if(((bit15(op1) == 0) and (bit15(op2) == 0) and (bit15(result) == 1)) or ((bit15(op1) == 1) and bit15(op2) == 0) and ((result)==0)):
           v = 1
        else:
           v = 0
        if(result > 65536):
            c = 1
        else:
            c = 0
    if(opcode == 1):
        result = op1-op2;
        if(((bit15(op1) == 0) and (bit15(op2) == 1) and (bit15(result) == 1)) or ((bit15(op1) == 1) and bit15(op2) == 0) and (bit15(result)) == 0):
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
        if((immediate & 0xF) > 0):
            result = rshift(op1, (immediate & 0xF))
        else:
            result = op1
    if(opcode == 9):
        result = op1 << (immediate & 0xF)
    if(opcode == 10):
        if((immediate & 0xF) > 0):
            result = (op1 << (16 - (immediate & 0xF))) | (rshift(op1, (immediate & 0xF)))
        else:
            result = op1
    if(opcode == 11):
        #print('op1:'+str(op1))
        #print('op2:'+str(op2))
        result = op1-op2;
        #print("result" + str(result))
        if(((bit15(op1) == 0) and (bit15(op2) == 1) and (bit15(result) == 1)) or ((bit15(op1) == 1) and bit15(op2) == 0) and (bit15(result)) == 0):
           v = 1
        else:
           v = 0
        if(((result & 0x7fffffff) >= 65536)):
           c = 1
        else:
           c = 0
    if(opcode == 12):
        result = immediate
    if(opcode == 13):
        result = None
    if(opcode == 14):
        result = None
    if(opcode == 15):
        result = None
    #print(result)
    #print(opcode)
    if((opcode == 1) or (opcode == 2) or (opcode == 0) or (opcode == 11)):
        if(result == 0 or result == None):
            res['n'] = 0
        elif(bit15(result)):
            res['n'] = 1
        else:
            res['n'] = 0
        if((result & 0xFFFF) == 0):
            res['z'] = 1
        else:
            res['z'] = 0
        if(opcode != 2):
            res['v'] = v
            res['c'] = c
    if((condition == 0) or ((condition == 1) and (zin == 1)) or ((condition == 2) and (nin == vin)) or ((condition == 3) and (nin != vin))):
        res['cond_succ']= 1
    else:
        res['cond_succ'] = 0
    if(opcode == 11):
        result = None
    res['res'] = result
    return res

text_file = sys.argv[1]
#print(text_file)
reg = [None] * 8
mem = [None] * 128
linecnt = -1
with open(text_file) as f:
    line_number = 0
    din = ""
    c=0
    v=0
    z=0
    n=0
    #for line in range(1,127):
    #for line in f:
    wr = open('data.txt',"w")
    for line in range(0,1023):
        linecnt = linecnt + 1
        line = str(random.randint(0,65535))
    #for line in f:
    #    linecnt = 10
        bin_string = format(int(line,16),'016b')
        if(linecnt < 8):
            opcode = '0110'
        else:
            opcode = bin_string[2:6]
        #condition = bin_string[:2]
        if(linecnt < 8):
            destination_reg = format(linecnt,'03b')
            condition = '00'
        else:
            destination_reg = bin_string[6:9]
            condition = bin_string[:2]
        operand_1 = bin_string[9:12]
        operand_2=bin_string[12:15]
        #destination_reg=bin_string[6:9]
        immediate_operand=bin_string[9:16]
        output_string = condition+opcode+destination_reg+immediate_operand
        if(linecnt != 1022):
            wr.write(hex(int(output_string,2))[2:] + "\n")
            print(output_string)
        else:
            wr.write('3c00\n')
        if(int(opcode,2) == 11):
            operand_1 = operand_1
            operand_2 = operand_2
        if(int(opcode,2) != 0xF):
            alu_result = alu(reg[int(operand_1,2)],reg[int(operand_2,2)],int(opcode,2),int(immediate_operand,2),int(condition,2),c,v,z,n)
            if(alu_result['cond_succ'] == 1):
                #print('succ')
                if(alu_result['res'] != None):
                    reg[int(destination_reg,2)] = (alu_result['res'] & 0xFFFF)
                elif(int(opcode,2) == 13): #load
                    #print('load')
                    reg[int(destination_reg,2)] = mem[(reg[int(operand_1,2)] & 0x7F)]
                    if( reg[int(destination_reg,2)]  == None):
                         reg[int(destination_reg,2)] = 0 
                elif(int(opcode,2) == 14): #store
                    #print('store')
                    mem[(reg[int(operand_1,2)] & 0x7f)] = reg[int(destination_reg,2)]
                if(int(opcode,2) == 0 or int(opcode,2) == 1 or int(opcode,2) == 2 or int(opcode,2) == 11):
                    n = alu_result['n']
                    z = alu_result['z']
                    if(int(opcode,2) != 2):
                        v = alu_result['v']
                        c = alu_result['c']
            #else:
                #print(operand_1)
                #print(operand_2)
                #print(opcode)
        print('c:'+str(c))
        print('v:'+str(v))
        print('z:'+str(z))
        print('n:'+str(n))
        print(reg)
            #print("data_in_reg <= 16'b"+din+";")
        #print(din)
        #print("#60")
        #wr.write(hex(int(din,2))[2:]+"\n")
print(reg)
print(mem)
wr.close()
