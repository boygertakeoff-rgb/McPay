from flask import Flask, request, jsonify
import random, datetime

app = Flask(__name__)

# Memoria - depois liga no Postgres
saldos = {"258840000001": 8245.50, "258820000002": 5000.00}

def gerar_ref():
    return f"000{random.randint(128000,129999)}"

@app.route("/")
def home():
    return jsonify({
        "McPay": "Moçambique",
        "versao": "1.0 - Nampula",
        "status": "Online - Aprovado BdM",
        "fluxos": ["USSD *258#", "QR Fixo MCP023", "P2P @joao.mz", "Shop MC"]
    })

@app.route("/ussd", methods=["GET","POST"])
def ussd():
    data = request.args if request.method=="GET" else request.form
    text = data.get("text","")
    phone = data.get("phoneNumber","258840000001")
    
    if text == "":
        return "CON McPay *258# Nampula\n1. Meu Saldo\n2. Enviar\n3. Pagar Shop MC\n4. Sair"
    
    if text == "1":
        saldo = saldos.get(phone, 0)
        return f"END Saldo: {saldo:.2f} MT\nMcPay Nampula"
    
    if text == "3":
        return "CON Shop MC\nDigite valor:"
    
    if text.startswith("3*"):
        try:
            valor = float(text.split("*")[1])
            if saldos.get(phone,0) < valor:
                return "END Saldo insuficiente!"
            saldos[phone] -= valor
            ref = gerar_ref()
            return f"END Pagamento OK!\nShop MC: {valor:.2f} MT\nRef: {ref}\nSaldo: {saldos[phone]:.2f} MT"
        except:
            return "END Valor invalido"
    
    return "END Obrigado McPay!"

@app.route("/api/transfer", methods=["POST"])
def transfer():
    d = request.get_json()
    de = d.get("de","258840000001")
    para = d.get("para","258820000002")
    valor = float(d.get("valor",1500))
    if saldos.get(de,0) < valor:
        return jsonify({"erro": "Saldo insuficiente"}), 400
    saldos[de]-=valor
    saldos[para]=saldos.get(para,0)+valor
    ref = gerar_ref()
    return jsonify({
        "comprovativo": ref,
        "data": "23 Out 2025 14:35",
        "valor": f"{valor:.2f} MT",
        "taxa": "0,00 MT",
        "de": "João Silva *84****12",
        "para": "Maria Chissano *62****89",
        "saldo": f"{saldos[de]:.2f} MT",
        "sms": f"MPY{random.randint(100000,999999)}"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
