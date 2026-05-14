'use client';

import { useEffect, useState } from 'react';

interface UserProfileProps {
  usuario: any;
}

interface TarjetaGuardada {
  tarjeta_id: number;
  titular: string;
  ultimos4: string;
  marca: string;
  tipo_tarjeta?: string;
  fabricante?: string;
  entidad_bancaria?: string;
}

export default function UserProfile({ usuario }: UserProfileProps) {
  const [editando, setEditando] = useState(false);
  const [datosEdit, setDatosEdit] = useState({
    nombre: usuario.nombre || '',
    apellido: usuario.apellido || '',
    email: usuario.email || '',
    telefono: usuario.telefono || '',
    direccion: usuario.direccion || '',
  });

  const [tarjeta, setTarjeta] = useState({
    numero: '',
    titular: '',
    vencimiento: '',
    cvv: '',
  });

  const [agregarTarjeta, setAgregarTarjeta] = useState(false);
  const [tarjetasGuardadas, setTarjetasGuardadas] = useState<TarjetaGuardada[]>([]);
  const [mensaje, setMensaje] = useState({ tipo: '', texto: '' });

  useEffect(() => {
    const cargarTarjeta = async () => {
      try {
        const response = await fetch(`http://localhost:5000/tarjeta-usuario/${usuario.usuario_id}`);
        const data = await response.json();
        if (response.ok) {
          setTarjetasGuardadas(Array.isArray(data.tarjetas) ? data.tarjetas : []);
        }
      } catch {
        // Ignoramos error silenciosamente para no romper el perfil.
      }
    };

    cargarTarjeta();
  }, [usuario.usuario_id]);

  const handleCambioEdit = (campo: string, valor: string) => {
    setDatosEdit((prev) => ({ ...prev, [campo]: valor }));
  };

  const handleCambioTarjeta = (campo: string, valor: string) => {
    setTarjeta((prev) => ({ ...prev, [campo]: valor }));
  };

  const handleGuardarDatos = async () => {
    setMensaje({ tipo: '', texto: '' });
    try {
      const response = await fetch('http://localhost:5000/actualizar-perfil', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          usuario_id: usuario.usuario_id,
          ...datosEdit,
        }),
      });

      const data = await response.json();
      if (!response.ok) {
        setMensaje({ tipo: 'error', texto: data.error || 'No se pudo actualizar el perfil.' });
        return;
      }

      setMensaje({ tipo: 'exito', texto: 'Perfil actualizado exitosamente.' });
      setEditando(false);
    } catch {
      setMensaje({ tipo: 'error', texto: 'No se pudo conectar con el servidor.' });
    }
  };

  const handleGuardarTarjeta = async () => {
    setMensaje({ tipo: '', texto: '' });

    if (!tarjeta.numero || !tarjeta.titular || !tarjeta.vencimiento || !tarjeta.cvv) {
      setMensaje({ tipo: 'error', texto: 'Por favor completa todos los campos de la tarjeta.' });
      return;
    }

    try {
      const response = await fetch('http://localhost:5000/agregar-tarjeta', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          usuario_id: usuario.usuario_id,
          numero: tarjeta.numero,
          titular: tarjeta.titular,
          vencimiento: tarjeta.vencimiento,
          cvv: tarjeta.cvv,
        }),
      });

      const data = await response.json();
      if (!response.ok) {
        setMensaje({ tipo: 'error', texto: data.error || 'No se pudo guardar la tarjeta.' });
        return;
      }

      setMensaje({ tipo: 'exito', texto: 'Tarjeta guardada exitosamente.' });
      setAgregarTarjeta(false);
      setTarjeta({ numero: '', titular: '', vencimiento: '', cvv: '' });
      if (data.tarjeta) {
        setTarjetasGuardadas((prev) => [data.tarjeta, ...prev]);
      }
    } catch {
      setMensaje({ tipo: 'error', texto: 'No se pudo conectar con el servidor.' });
    }
  };

  const handleEliminarTarjeta = async (tarjetaId: number) => {

    setMensaje({ tipo: '', texto: '' });
    try {
      const response = await fetch(`http://localhost:5000/eliminar-tarjeta/${tarjetaId}`, {
        method: 'DELETE',
      });
      const data = await response.json();

      if (!response.ok) {
        setMensaje({ tipo: 'error', texto: data.error || 'No se pudo eliminar la tarjeta.' });
        return;
      }

      setTarjetasGuardadas((prev) => prev.filter((tarjetaActual) => tarjetaActual.tarjeta_id !== tarjetaId));
      setMensaje({ tipo: 'exito', texto: 'Tarjeta eliminada correctamente.' });
    } catch {
      setMensaje({ tipo: 'error', texto: 'No se pudo conectar con el servidor.' });
    }
  };

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-slate-900">Perfil de Usuario</h2>

      {/* Mensaje de estado */}
      {mensaje.texto && (
        <div
          className={`rounded-3xl p-4 ${
            mensaje.tipo === 'exito'
              ? 'border border-green-200 bg-green-50 text-green-700'
              : 'border border-red-200 bg-red-50 text-red-700'
          }`}
        >
          {mensaje.texto}
        </div>
      )}

      {/* Datos Personales */}
      <div className="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
        <div className="mb-6 flex items-center justify-between">
          <h3 className="text-xl font-bold text-slate-900">Datos Personales</h3>
          {!editando && (
            <button
              onClick={() => setEditando(true)}
              className="rounded-full bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700"
            >
              Editar
            </button>
          )}
        </div>

        {editando ? (
          <div className="space-y-4">
            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-slate-700">Nombre</label>
                <input
                  type="text"
                  value={datosEdit.nombre}
                  onChange={(e) => handleCambioEdit('nombre', e.target.value)}
                  className="mt-2 w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 focus:border-blue-500 focus:outline-none"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700">Apellido</label>
                <input
                  type="text"
                  value={datosEdit.apellido}
                  onChange={(e) => handleCambioEdit('apellido', e.target.value)}
                  className="mt-2 w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 focus:border-blue-500 focus:outline-none"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700">Email</label>
                <input
                  type="email"
                  value={datosEdit.email}
                  onChange={(e) => handleCambioEdit('email', e.target.value)}
                  className="mt-2 w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 focus:border-blue-500 focus:outline-none"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700">Teléfono</label>
                <input
                  type="text"
                  value={datosEdit.telefono}
                  onChange={(e) => handleCambioEdit('telefono', e.target.value)}
                  className="mt-2 w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 focus:border-blue-500 focus:outline-none"
                />
              </div>
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-slate-700">Dirección</label>
                <input
                  type="text"
                  value={datosEdit.direccion}
                  onChange={(e) => handleCambioEdit('direccion', e.target.value)}
                  className="mt-2 w-full rounded-2xl border border-slate-300 bg-slate-50 px-4 py-3 focus:border-blue-500 focus:outline-none"
                />
              </div>
            </div>

            <div className="flex justify-end gap-3 border-t border-slate-200 pt-4">
              <button
                onClick={() => setEditando(false)}
                className="rounded-full bg-slate-200 px-6 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-300"
              >
                Cancelar
              </button>
              <button
                onClick={handleGuardarDatos}
                className="rounded-full bg-blue-600 px-6 py-2 text-sm font-semibold text-white hover:bg-blue-700"
              >
                Guardar Cambios
              </button>
            </div>
          </div>
        ) : (
          <div className="grid gap-4 md:grid-cols-2">
            <div>
              <p className="text-sm font-medium text-slate-600">Nombre</p>
              <p className="text-lg font-semibold text-slate-900">{datosEdit.nombre}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-slate-600">Apellido</p>
              <p className="text-lg font-semibold text-slate-900">{datosEdit.apellido}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-slate-600">Email</p>
              <p className="text-lg font-semibold text-slate-900">{datosEdit.email}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-slate-600">Teléfono</p>
              <p className="text-lg font-semibold text-slate-900">{datosEdit.telefono}</p>
            </div>
            <div className="md:col-span-2">
              <p className="text-sm font-medium text-slate-600">Dirección</p>
              <p className="text-lg font-semibold text-slate-900">{datosEdit.direccion}</p>
            </div>
          </div>
        )}
      </div>

      {/* Tarjeta de Crédito/Débito */}
      <div className="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
        <div className="mb-6 flex items-center justify-between">
          <h3 className="text-xl font-bold text-slate-900">Tarjeta de Crédito/Débito</h3>
          {!agregarTarjeta && (
            <button
              onClick={() => setAgregarTarjeta(true)}
              className="rounded-full bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700"
            >
              Agregar Tarjeta
            </button>
          )}
        </div>

        {tarjetasGuardadas.length > 0 && (
          <div className="mb-4 space-y-3">
            {tarjetasGuardadas.map((tarjetaGuardada) => (
              <div
                key={tarjetaGuardada.tarjeta_id}
                className="flex items-center justify-between rounded-2xl border border-slate-200 bg-slate-50 p-4"
              >
                <div>
                  <p className="font-semibold text-slate-800">
                    {tarjetaGuardada.tipo_tarjeta || 'No identificado'} - {tarjetaGuardada.fabricante || tarjetaGuardada.marca} - ****{tarjetaGuardada.ultimos4}
                  </p>
                  <p className="text-sm text-slate-600">
                    {tarjetaGuardada.entidad_bancaria || 'Entidad no identificada'}
                  </p>
                </div>
                <button
                  onClick={() => handleEliminarTarjeta(tarjetaGuardada.tarjeta_id)}
                  className="rounded-full bg-red-600 px-4 py-2 text-sm font-semibold text-white hover:bg-red-700"
                >
                  Eliminar
                </button>
              </div>
            ))}
          </div>
        )}

        {/* Modal para agregar tarjeta */}
        {agregarTarjeta && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
            <div className="w-full max-w-md rounded-3xl bg-white p-8 shadow-xl">
              <h3 className="text-xl font-bold text-slate-900 mb-4">Agregar Tarjeta</h3>
              <p className="mb-6 text-slate-700">Completa los datos de tu tarjeta para agregarla a tu perfil.</p>
              <div className="space-y-4">
                <input
                  type="text"
                  placeholder="Número de tarjeta"
                  value={tarjeta.numero}
                  onChange={(e) => handleCambioTarjeta('numero', e.target.value)}
                  className="w-full rounded-lg border border-gray-300 p-2"
                />
                <input
                  type="text"
                  placeholder="Titular"
                  value={tarjeta.titular}
                  onChange={(e) => handleCambioTarjeta('titular', e.target.value)}
                  className="w-full rounded-lg border border-gray-300 p-2"
                />
                <input
                  type="text"
                  placeholder="Vencimiento (MM/AA)"
                  value={tarjeta.vencimiento}
                  onChange={(e) => handleCambioTarjeta('vencimiento', e.target.value)}
                  className="w-full rounded-lg border border-gray-300 p-2"
                />
                <input
                  type="text"
                  placeholder="CVV"
                  value={tarjeta.cvv}
                  onChange={(e) => handleCambioTarjeta('cvv', e.target.value)}
                  className="w-full rounded-lg border border-gray-300 p-2"
                />
              </div>
              <div className="mt-4 flex justify-end gap-3">
                <button
                  onClick={() => setAgregarTarjeta(false)}
                  className="rounded-full bg-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-400"
                >
                  Cancelar
                </button>
                <button
                  onClick={handleGuardarTarjeta}
                  className="rounded-full bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
                >
                  Guardar
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ...existing code... */}
      </div>
    </div>
  );
}
